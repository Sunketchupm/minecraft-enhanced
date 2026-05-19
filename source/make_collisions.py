import os

def parse_model(model_file: str):
    vtx = []
    tris = []
    with open(model_file, "r") as file:
        in_vtx = False
        in_tris = False
        vtx_group_splits = []
        tris_in_group = []
        vtx_in_group = []

        # First pass: Gfx
        for line in file:
            line = line.strip()
            if line.startswith("Gfx") and "tri_0" in line:
                in_tris = True
            elif in_tris:
                if ";" in line:
                    in_tris = False
                    tris.append(tris_in_group)
                    continue
                if line.startswith("gsSPVertex"):
                    count_start = line.find("+") + 2
                    count_end = line.find(",", count_start)
                    tris_offset = int(line[count_start:count_end])
                    if tris_offset > 0:
                        vtx_group_splits.append(tris_offset)
                        tris.append(tris_in_group)
                        tris_in_group = []
                elif line.startswith("gsSP1Triangle"):
                    args_start = line.find("(") + 1
                    args_end = line.find(")")
                    args_line = line[args_start:args_end]
                    normalized_line = (args_line.replace(" ", "").replace(",", " "))[:-2]
                    args = normalized_line.split()
                    for i, arg in enumerate(args):
                        args[i] = int(arg)
                    tris_in_group.append(args)

        # Second pass: Vtx
        file.seek(0)
        vtx_line = 0
        for line in file:
            line = line.strip()
            if line.startswith("Vtx"):
                in_vtx = True
                vtx_line = 0
            elif in_vtx:
                if ";" in line:
                    in_vtx = False
                    vtx.append(vtx_in_group)
                    continue
                if vtx_line in vtx_group_splits:
                    vtx.append(vtx_in_group)
                    vtx_in_group = []
                normalized_line = line.replace("{", "").replace("}", "").replace(" ", "").replace(",", " ")
                vtx_in_group.append(normalized_line.split())
                vtx_line += 1
    return (vtx, tris)

def write_model(base_shapes: list):
    with open("shapes.lua", "w") as file:
        file.write("-- THIS FILE IS AUTO-GENERATED --\n"
            "local Shapes = {}\n"
        )
        for i, shape in enumerate(base_shapes):
            shape_index = shape[0][-1]
            file.write(f"Shapes.SHAPE_{shape[0][:-2].upper()} = {shape_index}\n")
            file.write(f"Shapes[{shape_index}] = " + "{\n")
            file.write("    vertices = {\n")
            for vertex_group in shape[1]:
                file.write("        {\n")
                for vertex in vertex_group:
                    file.write("            { " + f"x = {int(vertex[0])*2}, y = {int(vertex[1])*2}, z = {int(vertex[2])*2}, tu = {vertex[4]}, tv = {vertex[5]}, r = {vertex[6]}, g = {vertex[7]}, b = {vertex[8]}, a = {vertex[9]}" + " },\n")
                file.write("        },\n")
            file.write("    },\n")
            file.write("    triangles = {\n")
            for triangle_group in shape[2]:
                file.write("        {\n")
                for tris in triangle_group:
                    file.write("            { " + f"{tris[0]}, {tris[1]}, {tris[2]}" + " },\n")
                file.write("        },\n")
            file.write("    },\n")
            file.write("}\n")
        file.write("return Shapes")

def write_collision(base_shapes: list):
    SURFACE_COUNT = 11

    write_collisions = []
    collision_lookup = {
        0: "SURFACE_DEFAULT",
        1: "SURFACE_BURNING",
        2: "SURFACE_DEATH_PLANE",
        3: "SURFACE_INSTANT_QUICKSAND",
        4: "SURFACE_SHALLOW_QUICKSAND",
        5: "SURFACE_NOT_SLIPPERY",
        6: "SURFACE_SLIPPERY",
        7: "SURFACE_VERY_SLIPPERY",
        8: "SURFACE_HANGABLE",
        9: "SURFACE_VANISH_CAP_WALLS",
        10: "SURFACE_RAYCAST",
    }

    for i, shape in enumerate(base_shapes):
        shape_index = shape[0][-1]
        for surface_index in range(SURFACE_COUNT):
            for line in shape[3].splitlines():
                line = line.strip()
                if line.startswith("const Collision"):
                    written_index = surface_index
                    if surface_index == 10:
                        written_index = 255
                    write_collisions.append(f"const Collision mce_block_col_{written_index}_{shape_index} = " + "{\n")
                elif line.startswith("COL_TRI_INIT"):
                    surface_param_end = line.find(",", 12)
                    surface_type = collision_lookup[surface_index]
                    write_collisions.append(f"COL_TRI_INIT({surface_type}{line[surface_param_end:]}\n")
                else:
                    write_collisions.append(line + "\n")

    with open("collision.inc.c", "w") as file:
        file.write("// THIS FILE IS AUTO-GENERATED //\n")
        file.writelines(write_collisions)

base_shapes = []
for root, dirs, files in os.walk("base"):
    shape_name = os.path.basename(root)
    gfx = ()
    collision = ""
    found_files = False
    for file in files:
        if file == "model.inc.c":
            gfx = parse_model(os.path.join(root, file))
            found_files = True
        elif file == "collision.inc.c":
            with open(os.path.join(root, file), "r") as col_file:
                collision = col_file.read()

    if found_files:
        base_shapes.append((shape_name, gfx[0], gfx[1], collision))
    base_shapes.sort()

write_model(base_shapes)
write_collision(base_shapes)