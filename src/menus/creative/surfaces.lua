local Utils = require("../utils")

local Surfaces = {}

local t = get_texture_info
local DEFAULT_TEX = t("nonehelp")
local NOCOL_TEX = t("nocolhelp")
local NOFALL_TEX = t("placeholder")
local NSLIP_TEX = t("nsliphelp")
local SLIP_TEX = t("sliphelp")
local VSLIP_TEX = t("vsliphelp")
local HANGABLE_TEX = t("hangablehelp")
local VWIND_TEX = t("vwindhelp")
local WATER_TEX = t("waterhelp")
local VANISH_TEX = t("vanishhelp")
local TOXIC_TEX = t("toxichelp")
local SHALLOWSAND_TEX = t("shallowsandhelp")
local QUICKSAND_TEX = t("quicksandhelp")
local LAVA_TEX = t("lavahelp")
local DEATH_TEX = t("deathhelp")
local CHECKPOINT_TEX = t("placeholder")
local BOUNCE_TEX = t("placeholder")
local CONVEYOR_TEX = t("conveyorhelp")
local FIRSTY_TEX = t("placeholder")
local WIDEKICK_TEX = t("placeholder")
local ANYKICK_TEX = t("placeholder")
local WKLESS_TEX = t("wklesshelp")
local DASH_TEX = t("placeholder")
local BOOST_TEX = t("placeholder")
local ABC_TEX = t("placeholder")
local JUMP_TEX = t("placeholder")
local CAPLESS_TEX = t("placeholder")
local BREAK_TEX = t("breakhelp")
local DISAPPEAR_TEX = t("placeholder")
local SHRINK_TEX = t("placeholder")
local SPRINGBOARD_TEX = t("placeholder")

---@class (exact) Description
    ---@field title string
    ---@field details {alias: string, type: string}
    ---@field lines {[1]: string, [2]: string, [3]: string, [4]: string}
    ---@field image TextureInfo

-- This is for the stuff in the box on the right side of the menu
-- {title = "", details = {alias = "Aliases: ", type = "Type: "}, lines = {"", "", "", ""}, image = }
---@type Description[]
local sSurfaceDescriptions = {
    {title = "Default", details = {alias = "Aliases: normal", type = "Type: Surface"}, lines = {"The default SM64 surface.", "Can't go wrong with it.", "", ""}, image = DEFAULT_TEX},
    {title = "No Collision", details = {alias = "Aliases: intangible / none", type = "Type: Surface"}, lines = {"Removes all surface collision.", "Best used with ", "transparent blocks.", ""}, image = NOCOL_TEX},
    {title = "No Fall Damage", details = {alias = "Aliases: nofall", type = "Type: Property"}, lines = {"Prevents players from taking", "any fall damage when landing", "on this block.", ""}, image = NOFALL_TEX},
    {title = "Slippery", details = {alias = "Aliases: slip", type = "Type: Surface"}, lines = {"A slippery surface players", "can slide off.", "", ""}, image = SLIP_TEX},
    {title = "Not Slippery", details = {alias = "Aliases: not slip / nslip", type = "Type: Surface"}, lines = {"A surface players can always", "walk on.", "", ""}, image = NSLIP_TEX},
    {title = "Very Slippery", details = {alias = "Aliases: very slip / vslip", type = "Type: Surface"}, lines = {"Players will always slide", "off this surface. Can sillykick", "if the slope isn't too steep.", "Cannot framewalk."}, image = VSLIP_TEX},
    {title = "Shallowsand", details = {alias = "Aliases: ssand", type = "Type: Surface"}, lines = {"Restricts movement and jump", "height. Doesn't sink", "the player.", ""}, image = SHALLOWSAND_TEX},
    {title = "Quicksand", details = {alias = "Aliases: qsand", type = "Type: Surface"}, lines = {"Hazardous surface that ", "instantly sinks any player  ", "upon contact.", ""}, image = QUICKSAND_TEX},
    {title = "Lava", details = {alias = "Aliases: N/A", type = "Type: Surface"}, lines = {"Hazardous surface that", "launches the player upwards", "and deals damage.", ""}, image = LAVA_TEX},
    {title = "Toxic Gas", details = {alias = "Aliases: toxic / gas", type = "Type: Effect"}, lines = {"Hazardous gas that slowly", "depletes the player's HP. Has", "no collision.", ""}, image = TOXIC_TEX},
    {title = "Death", details = {alias = "Aliases: N/A", type = "Type: Surface"}, lines = {"Hazardous surface that kills", "the player if they're 10.25", "blocks above its surface.", ""}, image = DEATH_TEX},
    {title = "Vanish", details = {alias = "Aliases: N/A", type = "Type: Surface"}, lines = {"Acts like a normal surface, but", "can be phased through with the", "Vanish Cap.", ""}, image = VANISH_TEX},
    {title = "Hangable", details = {alias = "Aliases: hang", type = "Type: Surface"}, lines = {"Holding A while touching this", "surface's ceiling will make the", "player hang on until they let", "go."}, image = HANGABLE_TEX},
    {title = "Water", details = {alias = "Aliases: swim", type = "Type: Effect"}, lines = {"A block of water. Overlap", "multiple blocks to swim", "between them.", ""}, image = WATER_TEX},
    {title = "Vertical Wind", details = {alias = "Aliases: vwind", type = "Type: Effect"}, lines = {"A gust of wind that carries", "the player upwards. Best used", "with barrier blocks.", ""}, image = VWIND_TEX},
    {title = "Checkpoint", details = {alias = "Aliases: respawn", type = "Type: Property"}, lines = {"A surface block with standard", "properties, standing on it", "creates a respawn point.", ""}, image = CHECKPOINT_TEX},
    {title = "Bounce", details = {alias = "Aliases: N/A", type = "Type: Surface"}, lines = {"Bounces the player back when", "touching any surface face. Works", "best with the Wing Cap.", ""}, image = BOUNCE_TEX},
    {title = "Conveyor", details = {alias = "Aliases: N/A", type = "Type: Property"}, lines = {"Pushes the player in the", "direction of the arrow.", "Possible to hang on its", "ceiling."}, image = CONVEYOR_TEX},
    {title = "Firsty", details = {alias = "Aliases: firstie", type = "Type: Property"}, lines = {"When performing a wallkick on", "this surface, speed will always" , "be maintained.", ""}, image = FIRSTY_TEX},
    {title = "Widekick", details = {alias = "Aliases: wide / wide wallkick", type = "Type: Property"}, lines = {"Wallkicks can be performed", "from any angle facing this", "surface's wall.", ""}, image = WIDEKICK_TEX},
    {title = "Anykick", details = {alias = "Aliases: any bonk", type = "Type: Property"}, lines = {"Wallkicks can be performed", "after any bonking action such", "as dives, ground pounds, ", "ceilings, and 'out of bounds'."}, image = ANYKICK_TEX},
    {title = "Wallkickless", details = {alias = "Aliases: no wallkick / wkless", type = "Type: Property"}, lines = {"Attempting to wallkick on this", "surface will always fail.", "", ""}, image = WKLESS_TEX},
    {title = "Dash Panel", details = {alias = "Aliases: dash", type = "Type: Surface"}, lines = {"Forces the player to dash at", "great speeds when walking on", "this surface's floor.", ""}, image = DASH_TEX},
    {title = "Booster", details = {alias = "Aliases: boost", type = "Type: Effect"}, lines = {"Dractically increases the", "player's speed when within this", "surface block. Has no collision.", ""}, image = BOOST_TEX},
    {title = "Jumpless", details = {alias = "Aliases: no a / abc", type = "Type: Property"}, lines = {"Attempting to jump or wallkick", "on this surface will always", "fail.", ""}, image = ABC_TEX},
    {title = "Jump Pad", details = {alias = "Aliases: jpad", type = "Type: Surface"}, lines = {"Pressing A while standing on", "this surface will launch the", "player up to 7 blocks in the ", "air."}, image = JUMP_TEX},
    {title = "Capless", details = {alias = "Aliases: remove caps", type = "Type: Property"}, lines = {"If any players are wearing a ", "special cap when above this", "block, they will revert to", "wearing a normal cap."}, image = CAPLESS_TEX},
    {title = "Breakable", details = {alias = "Aliases: break", type = "Type: Property"}, lines = {"Attacking this surface will", "break the block completely.", "", ""}, image = BREAK_TEX},
    {title = "Disappearing", details = {alias = "Aliases: disappear", type = "Type: Property"}, lines = {"Touching this surface will", "quickly make this surface", "disappear entirely.", ""}, image = DISAPPEAR_TEX},
    {title = "Shrinking", details = {alias = "Aliases: shrink", type = "Type: Property"}, lines = {"Standing on this surface will", " slowly shrink the block until", "it disappears entirely.", ""}, image = SHRINK_TEX},
    {title = "Springboard", details = {alias = "Aliases: spring / noteblock", type = "Type: Surface"}, lines = {"Going onto this surface will", "make the player immediately jump", "high.", ""}, image = SPRINGBOARD_TEX},
}

---@param rect Rectangle
---@param index integer
function Surfaces.render_description_box(rect, index)
    local description_rect = {
        x = rect.x + rect.width * 0.36,
        y = rect.y + rect.height * 0.18,
        width = rect.width * 0.5,
        height = rect.height * 0.78
    }
    local rect_colors = {
        normal = { r = 0, g = 16, b = 69, a = 255 },
        shine = { r = 255, g = 255, b = 255, a = 255 },
        shade = { r = 255, g = 255, b = 255, a = 255 }
    }
    Utils.render_bordered_rectangle(description_rect, rect_colors, 0.01, true)

    local desc_x = description_rect.x + rect.width * 0.03
    local desc_y = description_rect.y + rect.height * 0.03
    local text_scale = 0.5 * (rect.width/rect.height)
    local description = sSurfaceDescriptions[index]
    if not description then return end
    local lines = description.lines
    Utils.render_shadowed_text(description.title, desc_x, desc_y, text_scale * 2, WHITE)
    djui_hud_set_color(128, 128, 128, 255)
    djui_hud_print_text(description.details.alias, desc_x, desc_y + 55, text_scale * 0.9)
    djui_hud_print_text(description.details.type, desc_x, desc_y + 85, text_scale * 0.9)
    Utils.render_shadowed_text(lines[1], desc_x, desc_y + 115, text_scale, WHITE)
    Utils.render_shadowed_text(lines[2], desc_x, desc_y + 145, text_scale, WHITE)
    Utils.render_shadowed_text(lines[3], desc_x, desc_y + 175, text_scale, WHITE)
    Utils.render_shadowed_text(lines[4], desc_x, desc_y + 205, text_scale, WHITE)

    local image = description.image
    local image_scale = 0.7 * (rect.width/rect.height)
    local image_x = description_rect.x + description_rect.width * 0.5 - (image.width * image_scale) * 0.5
    local image_y = description_rect.y + description_rect.height - (image.height * image_scale) - 5
    djui_hud_set_color(255, 255, 255, 255)
    djui_hud_render_texture(image, image_x, image_y, image_scale, image_scale)
end

return Surfaces