-- Cleaned version of the AwesomeWM configuration file
-- Preserved structure, improved spacing, and consistent formatting
-- Module imports
pcall(require, "luarocks.loader")

local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
require("awful.hotkeys_popup.keys")

-- Error handling
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end

-- Variable definitions
beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")
beautiful.useless_gap = 5

terminal = "x-terminal-emulator"
editor = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor
modkey = "Mod4"

awful.layout.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.corner.nw,
}

-- Keyboard layout and clock
mykeyboardlayout = awful.widget.keyboardlayout()
mytextclock = wibox.widget.textclock()

-- Key bindings
globalkeys = gears.table.join(
    awful.key({ modkey }, "Return", function () awful.spawn(terminal) end,
        {description = "open a terminal", group = "launcher"}),

    awful.key({ modkey }, "d", function () awful.util.spawn("rofi -show drun") end,
        {description = "run application launcher", group = "launcher"}),

    awful.key({ modkey }, "c", function () awful.spawn("code") end,
        {description = "open VSCode", group = "launcher"}),

    awful.key({ modkey }, "b", function () awful.spawn("firefox") end,
        {description = "open Firefox", group = "launcher"}),

    awful.key({ modkey, "Shift" }, "Return", function () awful.spawn("nemo") end,
        {description = "open Nemo file manager", group = "launcher"}),

    awful.key({ modkey, "Shift" }, "r", awesome.restart,
        {description = "reload awesome", group = "awesome"}),

    awful.key({ modkey, "Shift" }, "q", awesome.quit,
        {description = "quit awesome", group = "awesome"})
)

root.keys(globalkeys)

-- Screen setup
awful.screen.connect_for_each_screen(function(s)
    awful.tag({ "CODE", "WWW", "TTY", "MSG", "SPOTIFY", "VID", "PLAY", "BRW", "Files" }, s, awful.layout.layouts[1])

    s.mypromptbox = awful.widget.prompt()
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
        awful.button({ }, 1, function () awful.layout.inc(1) end),
        awful.button({ }, 3, function () awful.layout.inc(-1) end),
        awful.button({ }, 4, function () awful.layout.inc(1) end),
        awful.button({ }, 5, function () awful.layout.inc(-1) end)
    ))

    s.mytaglist = awful.widget.taglist {
        screen = s,
        filter = awful.widget.taglist.filter.all
    }

    s.mytasklist = awful.widget.tasklist {
        screen = s,
        filter = awful.widget.tasklist.filter.currenttags
    }

    s.mywibox = awful.wibar({ position = "top", screen = s })
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        {
            layout = wibox.layout.fixed.horizontal,
            s.mytaglist,
            s.mypromptbox,
        },
        s.mytasklist,
        {
            layout = wibox.layout.fixed.horizontal,
            mykeyboardlayout,
            wibox.widget.systray(),
            mytextclock,
            s.mylayoutbox,
        },
    }
end)

-- Autostart applications
awful.spawn.with_shell("picom")
awful.spawn.with_shell("nitrogen --restore")
awful.spawn.with_shell("lxpolkit")
