local Shapes = require("shapes")
local BlockTextures = require("textures") ---@diagnostic disable-line: different-requires

local CASE_SHADED_SOLID_TEXTURE = 0
local CASE_SHADED_TRANSPARENT_TEXTURE = 1
local CASE_UNSHADED_SOLID_TEXTURE = 2
local CASE_UNSHADED_TRANSPARENT_TEXTURE = 3
local CASE_SHADED_SOLID_COLOR = 4
local CASE_SHADED_TRANSPARENT_COLOR = 5
local CASE_UNSHADED_SOLID_COLOR = 6
local CASE_UNSHADED_TRANSPARENT_COLOR = 7

---@param obj Object
local __get_shape_index = function (obj)
    return (obj.oAnimState >> 16) & 0xFF
end

local __get_object_identifer = function (obj)
    return tostring(obj.oAnimState) .. tostring(obj.oColor) .. tostring(obj.oOpacity)
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

        local case = cast_graph_node(node).parameter

        -- Set geometry mode
        local cmd_set_geometry_mode = gfx_get_command(gfx, 0)
        gfx_set_command(cmd_set_geometry_mode, "gsSPSetGeometryMode(G_SHADING_SMOOTH | G_SHADE | G_LIGHTING | G_ZBUFFER)")

        -- Set color combiner
        local cmd_set_color_combiner = gfx_get_command(gfx, 2)
        local combiner_cases = {
            [CASE_SHADED_SOLID_TEXTURE] = "gsDPSetCombineLERP(TEXEL0, 0, SHADE, 0, TEXEL0, 0, ENVIRONMENT, 0, TEXEL0, 0, SHADE, 0, TEXEL0, 0, ENVIRONMENT, 0)",
            [CASE_SHADED_TRANSPARENT_TEXTURE] = "gsDPSetCombineLERP(TEXEL0, 0, SHADE, 0, TEXEL0, 0, ENVIRONMENT, 0, TEXEL0, 0, SHADE, 0, TEXEL0, 0, ENVIRONMENT, 0)",
            [CASE_SHADED_SOLID_COLOR] = "gsDPSetCombineLERP(ENVIRONMENT, 0, SHADE, 0, ENVIRONMENT, 0, SHADE, 0, ENVIRONMENT, 0, SHADE, 0, ENVIRONMENT, 0, SHADE, 0)",
            [CASE_SHADED_TRANSPARENT_COLOR] = "gsDPSetCombineLERP(ENVIRONMENT, 0, SHADE, 0, ENVIRONMENT, 0, SHADE, 0, ENVIRONMENT, 0, SHADE, 0, ENVIRONMENT, 0, SHADE, 0)",
            [CASE_UNSHADED_SOLID_TEXTURE] = "gsDPSetCombineLERP(0, 0, 0, TEXEL0, TEXEL0, 0, ENVIRONMENT, 0, 0, 0, 0, TEXEL0, TEXEL0, 0, ENVIRONMENT, 0)",
            [CASE_UNSHADED_TRANSPARENT_TEXTURE] = "gsDPSetCombineLERP(0, 0, 0, TEXEL0, TEXEL0, 0, ENVIRONMENT, 0, 0, 0, 0, TEXEL0, TEXEL0, 0, ENVIRONMENT, 0)",
            [CASE_UNSHADED_SOLID_COLOR] = "gsDPSetCombineLERP(0, 0, 0, ENVIRONMENT, 0, 0, 0, ENVIRONMENT, 0, 0, 0, ENVIRONMENT, 0, 0, 0, ENVIRONMENT)",
            [CASE_UNSHADED_TRANSPARENT_COLOR] = "gsDPSetCombineLERP(0, 0, 0, ENVIRONMENT, 0, 0, 0, ENVIRONMENT, 0, 0, 0, ENVIRONMENT, 0, 0, 0, ENVIRONMENT)",
        }
        local combiner_case = combiner_cases[case] or "gsDPSetCombineLERP(TEXEL0, 0, SHADE, 0, TEXEL0, 0, ENVIRONMENT, 0, TEXEL0, 0, SHADE, 0, TEXEL0, 0, ENVIRONMENT, 0)"
        gfx_set_command(cmd_set_color_combiner, combiner_case)

        -- Set texture
        local texture_info = BlockTextures[obj.oAnimState & 0xFFFF]
        local texture = nil
        if texture_info then
            texture = texture_info.texture
        end
        local cmd_set_texture_image = gfx_get_command(gfx, 9)
        gfx_set_command(cmd_set_texture_image, "gsDPSetTextureImage(G_IM_FMT_RGBA, G_IM_SIZ_16b_LOAD_BLOCK, 1, %t)", texture)

        -- Set colors
        local cmd_environment_color = gfx_get_command(gfx, 14)
        local color = integer_to_color_table(obj.oColor)
        local color_cases = {
            [CASE_SHADED_SOLID_TEXTURE] = { command = "gsDPSetEnvColor(255, 255, 255, 255)", args = function () end},
            [CASE_SHADED_TRANSPARENT_TEXTURE] = { command = "gsDPSetEnvColor(255, 255, 255, %i)", args = function () return obj.oOpacity end },
            [CASE_SHADED_SOLID_COLOR] = { command = "gsDPSetEnvColor(%i, %i, %i, 255)", args = function () return color.r, color.g, color.b end },
            [CASE_SHADED_TRANSPARENT_COLOR] = { command = "gsDPSetEnvColor(%i, %i, %i, %i)", args = function () return color.r, color.g, color.b, obj.oOpacity end },
            [CASE_UNSHADED_SOLID_TEXTURE] = { command = "gsDPSetEnvColor(255, 255, 255, 255)", args = function () end},
            [CASE_UNSHADED_TRANSPARENT_TEXTURE] = { command = "gsDPSetEnvColor(255, 255, 255, %i)", args = function () return obj.oOpacity end },
            [CASE_UNSHADED_SOLID_COLOR] = { command = "gsDPSetEnvColor(%i, %i, %i, 255)", args = function () return color.r, color.g, color.b end },
            [CASE_UNSHADED_TRANSPARENT_COLOR] = { command = "gsDPSetEnvColor(%i, %i, %i, %i)", args = function () return color.r, color.g, color.b, obj.oOpacity end },
        }
        local color_case = color_cases[case] or { command = "gsDPSetEnvColor(255, 255, 255, 255)", args = function () end }
        gfx_set_command(cmd_environment_color, color_case.command, color_case.args())

        -- Compute vertices
        local cmd_vertices = gfx_get_command(gfx, 15)
        compute_vertices(obj, cmd_vertices)

        -- Build triangles
        local cmd_triangles = gfx_get_command(gfx, 16)
        build_triangles(obj, cmd_triangles)
    end

    -- Update the graph node display list
    local graph_node = cast_graph_node(node.next) --[[@as GraphNodeDisplayList]]
    graph_node.displayList = gfx

    node.flags = 0x600 | (node.flags & 0xFF);
end

---@param node GraphNode
function geo_switch_mce_block(node)
    local obj = geo_get_current_object()

    local case = obj.oOpacity == 255 and 2 or 3
    if mce_block_is_shaded(obj.oAnimState) then
        case = case - CASE_UNSHADED_SOLID_TEXTURE
    end
    if mce_block_is_colored(obj.oAnimState) then
        case = case + CASE_SHADED_SOLID_COLOR
    end

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

hook_event(HOOK_ON_OBJECT_UNLOAD, on_object_unload)