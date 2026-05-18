local Shapes = require("shapes")
local BlockTextures = require("textures")

---@param obj Object
local __get_shape_index = function (obj)
    return (obj.oAnimState >> 16) & 0xFF
end

local __get_object_identifer = function (obj)
    return tostring(obj.oAnimState) ..
            tostring(obj.oColor) ..
            tostring(obj.oOpacity) ..
            tostring(obj.oScaleX) ..
            tostring(obj.oScaleZ)
end

--- @param obj Object
--- @param gfx Gfx
--- Compute the vertices of the current shape and fill the vertex buffer.
local function compute_vertices(obj, gfx)
    local shape = Shapes[__get_shape_index(obj)]
    if not shape then return end

    local vertices = shape.vertices
    local num_vertices = #vertices

    -- Create a new or retrieve an existing vertex buffer for the shape
    -- Use the object pointer to form a unique identifier
    local vtx_name = "mce_block_vertices_" .. __get_object_identifer(obj)
    local vtx = vtx_get_from_name(vtx_name)
    if vtx == nil then
        vtx = vtx_create(vtx_name, num_vertices)
    else
        vtx_resize(vtx, num_vertices)
    end

    -- Update the vertex command
    gfx_set_command(gfx, "gsSPVertex(%v, %i, 0)", vtx, num_vertices)

    -- Fill the vertex buffer
    for _, vertex in ipairs(vertices) do
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
end

--- @param obj Object
--- @param gfx Gfx
--- Build the triangles for the current shape.
local function build_triangles(obj, gfx)
    local shape = Shapes[__get_shape_index(obj)]
    if not shape then return end

    local triangles = shape.triangles
    local num_triangles = #triangles

    -- Create a new or retrieve an existing triangles display list for the shape
    -- Use the object pointer to form a unique identifier
    local tris_name = "mce_block_triangles_" .. __get_object_identifer(obj)
    local tris = gfx_get_from_name(tris_name)
    if tris == nil then
        tris = gfx_create(tris_name, num_triangles + 1) -- +1 for the gsSPEndDisplayList command
    else
        gfx_resize(tris, num_triangles + 1)
    end

    -- Update the triangles command
    gfx_set_command(gfx, "gsSPDisplayList(%g)", tris)

    -- Fill the triangles display list
    for _, indices in ipairs(triangles) do
        if #indices == 6 then
            gfx_set_command(tris, "gsSP2Triangles(%i, %i, %i, 0, %i, %i, %i, 0)",
                indices[1], indices[2], indices[3],
                indices[4], indices[5], indices[6]
            )
        elseif #indices == 3 then
            gfx_set_command(tris, "gsSP1Triangle(%i, %i, %i, 0)",
                indices[1], indices[2], indices[3]
            )
        end
        tris = gfx_get_next_command(tris)
    end
    gfx_set_command(tris, "gsSPEndDisplayList()")
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

        -- Compute vertices
        local cmd_vertices = gfx_get_command(gfx, 17)
        compute_vertices(obj, cmd_vertices)

        -- Build triangles
        local cmd_triangles = gfx_get_command(gfx, 18)
        build_triangles(obj, cmd_triangles)
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