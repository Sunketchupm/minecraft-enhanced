local function invert_scrolling_mod_menu(_, value)
    gMenu.settings.invert_scroll = value
end

local function on_show_controls_mod_menu(_, show)
    gMenu.settings.show_controls = show
end

hook_mod_menu_checkbox("Invert Menu Mouse Scroll", false, invert_scrolling_mod_menu)
hook_mod_menu_checkbox("Show Controls", true, on_show_controls_mod_menu)