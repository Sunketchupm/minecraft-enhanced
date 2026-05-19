local Shapes = require("shapes")
local BlockTextures = require("textures")

local __get_object_identifer = function (obj)
    return tostring(obj.oAnimState) ..
            tostring(obj.oColor) ..
            tostring(obj.oOpacity) ..
            tostring(obj.oScaleX) ..
            tostring(obj.oScaleZ)
end

--- @param obj Object
--- @param gfx Gfx
--- Build the triangles for the current shape.
local function build_display_list(obj, gfx)
    local shape = Shapes[mce_block_get_shape_index(obj)]
    if not shape then return end

    local vertices = shape.vertices
    local triangles = shape.triangles

    ---@type { cmd: string, args: table }[]
    local commands = {}

    -- Vertices and triangles have the same count
    for i = 1, #vertices do
        local vtx_group = vertices[i]
        local vtx_name = "mce_block_vertices_" .. __get_object_identifer(obj) .. "_" .. i
        local vtx = vtx_get_from_name(vtx_name)
        if vtx == nil then
            vtx = vtx_create(vtx_name, #vtx_group)
        else
            vtx_resize(vtx, #vtx_group)
        end

        table.insert(commands, { cmd = "gsSPVertex(%v, %i, 0)", args = { vtx, vtx_group }})

        local tri_group = triangles[i]
        for _, tri in ipairs(tri_group) do
            table.insert(commands, { cmd = "gsSP1Triangle(%i, %i, %i, 0)", args = { tri[1], tri[2], tri[3] } })
        end
    end


    local tris_name = "mce_block_tris_" .. __get_object_identifer(obj)
    local tris_gfx = gfx_get_from_name(tris_name)
    if tris_gfx == nil then
        tris_gfx = gfx_create(tris_name, #commands + 1) -- +1 for the gsSPEndDisplayList command
    else
        gfx_resize(tris_gfx, #commands + 1)
    end

    gfx_set_command(gfx, "gsSPDisplayList(%g)", tris_gfx)

    -- Fill the display list
    for _, command in ipairs(commands) do
        local args = command.args
        if command.cmd:sub(1, 10) == "gsSPVertex" then
            local vtx = args[1]
            local vtx_group = args[2]
            gfx_set_command(tris_gfx, command.cmd, vtx, #vtx_group)
            for _, vertex in ipairs(vtx_group) do
                vtx.x = vertex.x
                vtx.y = vertex.y
                vtx.z = vertex.z
                vtx.tu = vertex.tu
                vtx.tv = vertex.tv
                vtx.r = vertex.r
                vtx.g = vertex.g
                vtx.b = vertex.b
                vtx.a = vertex.a
                vtx = vtx_get_next_vertex(vtx)
            end
        else
            local t1, t2, t3 = args[1], args[2], args[3]
            gfx_set_command(tris_gfx, command.cmd, t1, t2, t3)
        end
        tris_gfx = gfx_get_next_command(tris_gfx)
    end

    gfx_set_command(tris_gfx, "gsSPEndDisplayList()")
end

---@param node GraphNode
function geo_update_mce_block(node)
    local obj = geo_get_current_object()

    local gfx_name = "mce_block_dl_" .. __get_object_identifer(obj)
    local gfx = gfx_get_from_name(gfx_name)
    if not gfx then
        -- Get and copy the template to the newly created display list
        local gfx_template = gfx_get_from_name("mce_texture_block_dl")
        local gfx_template_length = gfx_get_length(gfx_template)
        gfx = gfx_create(gfx_name, gfx_template_length)
        gfx_copy(gfx, gfx_template, gfx_template_length)

        local is_transparent = cast_graph_node(node).parameter == 1
        local is_colored = mce_block_check_flag(obj, MCE_BLOCK_FLAG_COLORED)
        local is_unshaded = mce_block_check_flag(obj, MCE_BLOCK_FLAG_UNSHADED)
        local is_untiled = mce_block_check_flag(obj, MCE_BLOCK_FLAG_UNTILED)

        -- Set geometry mode
        local cmd_set_geometry_mode = gfx_get_command(gfx, 0)
        gfx_set_command(cmd_set_geometry_mode, "gsSPSetGeometryMode(G_SHADING_SMOOTH | G_SHADE | G_LIGHTING | G_ZBUFFER)")

        -- Set color combiner
        local combiner_case = "gsDPSetCombineLERP(TEXEL0, 0, SHADE, 0, TEXEL0, 0, ENVIRONMENT, 0, TEXEL0, 0, SHADE, 0, TEXEL0, 0, ENVIRONMENT, 0)"
        if is_unshaded then
            if is_colored then
                combiner_case = "gsDPSetCombineLERP(0, 0, 0, ENVIRONMENT, 0, 0, 0, ENVIRONMENT, 0, 0, 0, ENVIRONMENT, 0, 0, 0, ENVIRONMENT)"
            else
                combiner_case = "gsDPSetCombineLERP(0, 0, 0, TEXEL0, TEXEL0, 0, ENVIRONMENT, 0, 0, 0, 0, TEXEL0, TEXEL0, 0, ENVIRONMENT, 0)"
            end
        else
            if is_colored then
                combiner_case = "gsDPSetCombineLERP(ENVIRONMENT, 0, SHADE, 0, ENVIRONMENT, 0, SHADE, 0, ENVIRONMENT, 0, SHADE, 0, ENVIRONMENT, 0, SHADE, 0)"
            else
                combiner_case = "gsDPSetCombineLERP(TEXEL0, 0, SHADE, 0, TEXEL0, 0, ENVIRONMENT, 0, TEXEL0, 0, SHADE, 0, TEXEL0, 0, ENVIRONMENT, 0)"
            end
        end
        local cmd_set_color_combiner = gfx_get_command(gfx, 4)
        gfx_set_command(cmd_set_color_combiner, combiner_case)

        -- Set texture
        local texture_info = BlockTextures[obj.oAnimState & 0xFFFF]
        local texture = nil
        if texture_info then
            texture = texture_info.texture
        end
        local cmd_set_texture_image = gfx_get_command(gfx, 11)
        gfx_set_command(cmd_set_texture_image, "gsDPSetTextureImage(G_IM_FMT_RGBA, G_IM_SIZ_16b_LOAD_BLOCK, 1, %t)", texture)

        -- Set texture tiles
        if not is_untiled and not is_colored then
            local default_size = 60
            local scale_x = obj.oScaleX
            local scale_z = obj.oScaleZ
            local tile_x = default_size * (1/scale_x)
            local tile_z = default_size * (1/scale_z)
            local cmd_set_tile_size = gfx_get_command(gfx, 15)
            gfx_set_command(cmd_set_tile_size, "gsDPSetTileSize(0, 0, 0, %i, %i)", tile_x, tile_z)
        end

        -- Set colors
        local color = integer_to_color_table(obj.oColor)
        local color_case = { command = "gsDPSetEnvColor(255, 255, 255, 255)", args = function () end }
        if is_transparent then
            if is_colored then
                color_case = { command = "gsDPSetEnvColor(%i, %i, %i, %i)", args = function () return color.r, color.g, color.b, obj.oOpacity end }
            else
                color_case = { command = "gsDPSetEnvColor(255, 255, 255, %i)", args = function () return obj.oOpacity end }
            end
        else
            if is_colored then
                color_case = { command = "gsDPSetEnvColor(%i, %i, %i, 255)", args = function () return color.r, color.g, color.b end }
            else
                color_case = { command = "gsDPSetEnvColor(255, 255, 255, 255)", args = function () end }
            end
        end
        local cmd_environment_color = gfx_get_command(gfx, 16)
        gfx_set_command(cmd_environment_color, color_case.command, color_case.args())

        -- Build display list
        local cmd_display_list = gfx_get_command(gfx, 17)
        build_display_list(obj, cmd_display_list)
    end

    -- Update the graph node display list
    local graph_node = cast_graph_node(node.next) --[[@as GraphNodeDisplayList]]
    graph_node.displayList = gfx

    node.flags = 0x600 | (node.flags & 0xFF)
end

---@param node GraphNode
function geo_switch_mce_block(node)
    local obj = geo_get_current_object()

    local case = obj.oOpacity == 255 and 0 or 1
    local graph_node = cast_graph_node(node) --[[@as GraphNodeSwitchCase]]
    graph_node.selectedCase = case
end

--- @param obj Object
--- Delete allocated gfx and vtx for this object.
local function on_object_unload(obj)
    local gfx = gfx_get_from_name("mce_block_dl_" .. __get_object_identifer(obj))
    if gfx then gfx_delete(gfx) end

    local tris = gfx_get_from_name("mce_block_triangles_" .. __get_object_identifer(obj))
    if tris then gfx_delete(tris) end

    local vtx = vtx_get_from_name("mce_block_vertices_" .. __get_object_identifer(obj))
    if vtx then vtx_delete(vtx) end
end

local function on_warp()
    gfx_delete_all()
    vtx_delete_all()
end

hook_event(HOOK_ON_OBJECT_UNLOAD, on_object_unload)
hook_event(HOOK_ON_WARP, on_warp)