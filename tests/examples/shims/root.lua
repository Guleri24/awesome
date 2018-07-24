local root = {_tags={}}

local gtable = require("gears.table")

local hotkeys = nil

function root:tags()
    return root._tags
end

function root:size() --TODO use the screens
    return 0, 0
end

function root:size_mm()
    return 0, 0
end

function root.cursor() end

-- GLOBAL KEYBINDINGS --

local keys = {}

function root.keys(k)
    keys = k or keys
    return keys
end

-- FAKE INPUTS --

-- Turn keysym into modkey names
local conversion = {
    Super_L   = "Mod4",
    Control_L = "Control",
    Shift_L   = "Shift",
    Alt_L     = "Mod1",
    Super_R   = "Mod4",
    Control_R = "Control",
    Shift_R   = "Shift",
    Alt_R     = "Mod1",
}

-- The currently pressed modkeys.
local mods = {}
local function get_mods()
    local ret = {}

    for mod in pairs(mods) do
        table.insert(ret, mod)
    end

    return ret
end

local function add_modkey(key)
    if not conversion[key] then return end
    mods[conversion[key]] = true
end

local function remove_modkey(key)
    if not conversion[key] then return end
    mods[conversion[key]] = nil
end

local function match_modifiers(mods1, mods2)
    if #mods1 ~= #mods2 then return false end

    for _, mod1 in ipairs(mods1) do
        if not gtable.hasitem(mods2, mod1) then
            return false
        end
    end

    return true
end

local function execute_keybinding(key, event)
    -- It *could* be extracted from gears.object private API, but it's equally
    -- ugly as using the list used by the hotkey widget.
    if not hotkeys then
        hotkeys = require("awful.key").hotkeys
    end

    for _, v in ipairs(hotkeys) do
        if key == v.key and match_modifiers(v.mod, get_mods()) and v[event] then
            v[event]()
            return
        end
    end
end

local fake_input_handlers = {
    key_press      = function(key)
        add_modkey(key)
        if keygrabber._current_grabber then
            keygrabber._current_grabber(get_mods(), key, "press")
        else
            execute_keybinding(key, "press")
        end
    end,
    key_release    = function(key)
        remove_modkey(key)
        if keygrabber._current_grabber then
            keygrabber._current_grabber(get_mods(), key, "release")
        else
            execute_keybinding(key, "release")
        end
    end,
    button_press   = function() --[[TODO]] end,
    button_release = function() --[[TODO]] end,
    motion_notify  = function() --[[TODO]] end,
}

function root.fake_inputs(event_type, detail, x, y)
    assert(fake_input_handlers[event_type], "Unknown event_type")

    fake_input_handlers[event_type](detail, x, y)
end

return root

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
