local radical = require("radical")
local awful = require("awful")
require("awful.autofocus")
awful.rules = require("awful.rules")
-- Theme handling library
local beautiful = require("beautiful")
local gears = require("gears")
-- Notification library
local naughty = require("naughty")
local vicious = require("vicious")
local wibox = require("wibox")
local revelation = require("revelation")
local config = require("forgotten")
--local rad_tag = require("radical.impl.taglist")
local tyrannical = require("tyrannical")
netwidgetmode = 0

-- Functions

-- Function that executes any command given and returns the string it gets from commands output
function exec_cmd(cmd)
	local co = io.popen(cmd)
	local str = ""
	for line in co:lines() do
		str = str .. line
	end
	io.close(co)
	return str
end


-- Function that returns ip-address for ethernet or wlan depending which one is connected.
-- Priority is for ethernet so if both up ethernet ip-address is returned.
function get_ip()
	local str = ""
	if exec_cmd("ifconfig enp2s0 | grep 'inet'| cut -d':' -f2 | awk '{print $2}'") == "" then
		str = exec_cmd("ifconfig wlp4s0 | grep 'inet'| cut -d':' -f2 | awk '{print $2}'")
	else
		str = exec_cmd("ifconfig enp2s0 | grep 'inet'| cut -d':' -f2 | awk '{print $2}'")
	end
	return str		
end

function get_net_usage()
	if exec_cmd("ifconfig enp2s0 | grep 'inet'| cut -d ':' -f2 | awk '{print $2}'") == "" then
		if netwidgetmode == 0 then
			netwidgetmode = 1
			vicious.register(netwidget, vicious.widgets.net, '<span color="#CC9393">${wlp4s0 down_kb}, </span> <span color="#7F9F7F">${wlp4s0 up_kb} kb/s</span>', 3)
		end
		if netwidgetmode == 2 then
			vicious.register(netwidget, vicious.widgets.net, '<span color="#CC9393">${wlp4s0 down_kb} ,</span> <span color="#7F9F7F">${wlp4s0 up_kb} kb/s</span>', 3) 
			netwidgetmode = 1
		end
	else
		if netwidgetmode == 0 then
			netwidgetmode =2
			vicious.register(netwidget, vicious.widgets.net, '<span color="#CC9393">${enp2s0 down_kb} ,</span> <span color="#7F9F7F">${enp2s0 up_kb} kb/s</span>', 3)
		end
		if netwidgetmode == 1 then
			vicious.register(netwidget, vicious.widgets.net, '<span color="#CC9393">${enp2s0 down_kb} ,</span> <span color="#7F9F7F">${enp2s0 up_kb} kb/s</span>', 3)
			netwidgetmode = 2
		end
	end
end
-- Function which runs any program given once and only once
function run_once(prg)
	if prg == "dbus-launch nm-applet --sm-disable" then
		awful.util.spawn_with_shell("pgrep -u $USER -x " .. "nm-applet".. " || (" .. prg .. ") ")
	else
		awful.util.spawn_with_shell("pgrep -u $USER -x '" .. prg .. "' || (" .. prg .. ") ")
	end
end


-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end


-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init("/home/tapio/.config/awesome/themes/dunzor/theme.lua")
for s = 1, screen.count() do
	gears.wallpaper.maximized(beautiful.wallpaper, s, true)
end

-- Various configuration options
config.showTitleBar = false
config.themeName = "arrow"
config.noNotifyPopup = true
config.useListPrefix = true
config.deviceOnDesk = true
config.desktopIcon = true
config.advTermTB = true
config.scriptPath = awful.util.getdir("config") .. "/Scripts/"
config.scr = {
    pri = 1,
    sec = 3,
    music = 4,
    irc = 2,
    media = 5,
}

-- DEFINE FLOATING APPS
floatapps = {
	["Organizer"] = true,
	["Thunar"] = true,
}
-- Load the theme
config.load()
--config.themePath = awful.util.getdir("config") .. "/blind/" .. config.themeName .. "/"
--config.iconPath = config.themePath .. "Icon/"
--beautiful.init(config.themePath .. "/themeSciFi.lua")

revelation.init()
-- This is used later as the default terminal and editor to run.i
terminal = "urxvtc"
eclipse = "eclipse"
thunar = "thunar"
editor = "vim"
--chromium = "chromium"
firefox = "firefox-bin"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.tile.bottom,
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}

-- dofile(awful.util.getdir("config") .. "/baseRule.lua")

-- }}}

-- {{{ Tags
--  -- Define a tag table which will hold all screen tags.
tags = {
	  names  = { "1", "2", "3", "4", "5", "6"},
	  layout = { layouts[1], layouts[2], layouts[2], layouts[1], layouts[1], layouts[1]
}}

for s = 1, screen.count() do
	-- Each screen has its own tag table.
	tags[s] = awful.tag(tags.names, s, tags.layout)
end
 -- }}}
 
 -- applications menu
  require('freedesktop.utils')
  freedesktop.utils.terminal = terminal  -- default: "xterm"
  freedesktop.utils.icon_theme = 'gnome' -- look inside /usr/share/icons/, default: nil (don't use icon theme)
  require('freedesktop.menu')
  -- require("debian.menu")

  menu_items = freedesktop.menu.new()
  myawesomemenu = {
     { "manual", terminal .. " -e man awesome", freedesktop.utils.lookup_icon({ icon = 'help' }) },
     { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua", freedesktop.utils.lookup_icon({ icon = 'package_settings' }) },
     { "restart", awesome.restart, freedesktop.utils.lookup_icon({ icon = 'gtk-refresh' }) },
     { "quit", awesome.quit, freedesktop.utils.lookup_icon({ icon = 'gtk-quit' }) }
  }
  table.insert(menu_items, { "awesome", myawesomemenu, beautiful.awesome_icon })
  table.insert(menu_items, { "open terminal", terminal, freedesktop.utils.lookup_icon({icon = 'terminal'}) })
  -- table.insert(menu_items, { "Debian", debian.menu.Debian_menu.Debian, freedesktop.utils.lookup_icon({ icon = 'debian-logo' }) })

  mymainmenu = awful.menu.new({ items = menu_items, width = 150 })

  mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })


  -- desktop icons
  require('freedesktop.desktop')
  for s = 1, screen.count() do
        freedesktop.desktop.add_applications_icons({screen = s, showlabels = true})
        freedesktop.desktop.add_dirs_and_files_icons({screen = s, showlabels = true})
  end


-- {{{ Menu
-- Create a laucher widget and a main menu
--myawesomemenu = {
--   { "manual", terminal .. " -e man awesome" },
--   { "edit config", editor_cmd .. " " .. awesome.conffile },
--   { "restart", awesome.restart },
--   { "quit", awesome.quit }
--}

--mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
--				    { "ecplise", eclipse },
--				    { "filemanager", thunar },
--				    { "firefox", firefox },
 --                                   { "open terminal", terminal }
 --                                 }
 --                       })
--mylauncher_icon = wibox.widget.imagebox()
--mylauncher_icon:set_image(beautiful.awesome_icon)
--mylauncher = awful.widget.launcher({ mylauncher_icon,
          --                           menu = mymainmenu })
-- }}}

-- {{{ Wibox
--
--

-- Create battery widget
battery_widget = wibox.widget.textbox()

temp = require("temperature")
myTempWidget = wibox.widget.textbox()
myTempWidget_icon = wibox.widget.imagebox()
myTempWidget_icon:set_image("/home/tapio/.config/awesome/blind/arrow/Icon/temp.png")
myTempWidget:set_markup(temp.getTemp(60, 70))
myTempTimer = timer({ timeout = 45 })
myTempTimer:connect_signal("timeout", function() myTempWidget:set_markup(temp.getTemp(60, 70)) end)
myTempTimer:start()

--awful.hooks.timer.register(1, function() myTempWidget:set_text(temp.getTemp(60, 70)) end)
--
-- Create wired netusage widget
-- Initialize widget
--netwidget_wired = widget({ type = "textbox" })
--dnicon_wired = widget({ type = "imagebox" })
--upicon_wired = widget({ type = "imagebox" })
--dnicon_wired.image = image(beautiful.widget_net)
--upicon_wired.image = image(beautiful.widget_netup)
-- Register widget
--vicious.register(netwidget_wired, vicious.widgets.net, 'enp2s0: <span color="#CC9393">${enp2s0 down_kb} ,</span> <span color="#7F9F7F">${enp2s0 up_kb} kb/s</span>', 3)

-- Create wlan net usage widget
-- Initialize widget
--netwidget_wireless = widget({ type = "textbox" })
--dnicon_wireless = widget({ type = "imagebox" }) 
--upicon_wireless = widget({ type = "imagebox" })
--dnicon_wireless.image = image(beautiful.widget_net)
--upicon_wireless.image = image(beautiful.widget_netup)
--Register widget
--vicious.register(netwidget_wireless, vicious.widgets.net, 'wlp4s0: <span color="#CC9393">${wlp4s0 down_kb} ,</span> <span color="#7F9F7F">${wlp4s0 up_kb} kb/s</span>', 3)

netwidget_icon_up = wibox.widget.imagebox()
netwidget_icon_down = wibox.widget.imagebox()
netwidget_icon_up:set_image("/home/tapio/.config/awesome/blind/arrow/Icon/arrowUp.png")
netwidget_icon_down:set_image("/home/tapio/.config/awesome/blind/arrow/Icon/arrowDown.png")

netwidget = wibox.widget.textbox()
get_net_usage()
--netwidget:set_text(get_net_usage())


--rad_tag.taglist_watch_name_changes = true

-- Create IP address widget
ipwidget = wibox.widget.textbox()
ipwidget:set_text("IP: " .. get_ip() .. " ")

-- Create separator widget
separator = wibox.widget.textbox()
separator:set_text(" | ")

-- Create spacer widget
spacer = wibox.widget.textbox()
spacer:set_text(" ")

-- Create mem widget
memwidget = wibox.widget.textbox()
memwidget_icon = wibox.widget.imagebox()
memwidget_icon:set_image("/home/tapio/.config/awesome/blind/arrow/Icon/ram-16.png")
vicious.register(memwidget, vicious.widgets.mem, "$1% ($2MB/$3MB)", 13)

-- Create cpu widget
cpuwidget_icon = wibox.widget.imagebox()
cpuwidget_icon:set_image("/home/tapio/.config/awesome/blind/arrow/Icon/cpu.png")
cpuwidget = wibox.widget.textbox()
vicious.register(cpuwidget, vicious.widgets.cpu, "$1%")
-- Create a textclock widget
--mytextclock = awful.widget.textclock({ align = "right" })

--mytextclock = awful.widget.textclock("<span>%a %m/%d</span> @ %I:%M %p")

mytextclock = awful.widget.textclock("%a %b %d, %H:%M", 60)
local orglendar = require('orglendar')
orglendar.files = { "/home/tapio/Documents/Notes/deadlines.org" } 
orglendar.register(mytextclock)

-- Lets create MPD WIDGET
local awesompd = require("awesompd/awesompd")
mpd_widget = awesompd:create()
mpd_widget.font = "Terminus" 
mpd_widget.scrolling = true -- If true, the text in the widget will be scrolled
mpd_widget.output_size = 30 -- Set the size of widget in symbols
mpd_widget.update_interval = 10 -- Set the update interval in second

-- Set the folder where icons are
mpd_widget.path_to_icons = "/home/username/.config/awesome/awesompd/icons" 
-- Set the default music format for Jamendo streams. You can change
-- this option on the fly in awesompd itself.
-- possible formats: awesompd.FORMAT_MP3, awesompd.FORMAT_OGG
mpd_widget.jamendo_format = awesompd.FORMAT_OGG
mpd_widget.show_album_cover = true
mpd_widget.album_cover_size = 50 --max value 100
mpd_widget.mpd_config = "/etc/mpd.conf"
mpd_widget.browser = "firefox-bin"
-- Specify decorators on the left and the right side of the
-- widget. Or just leave empty strings if you decorate the widget
-- from outside.
mpd_widget.ldecorator = " "
mpd_widget.rdecorator = " "
-- Set all the servers to work with (here can be any servers you use)
mpd_widget.servers = {
   { server = "localhost",
        port = 6600 } }
-- Set the buttons of the widget
mpd_widget:register_buttons({ { "", awesompd.MOUSE_LEFT, mpd_widget:command_playpause() },
		 	       { "Control", awesompd.MOUSE_SCROLL_UP, mpd_widget:command_prev_track() },
 			       { "Control", awesompd.MOUSE_SCROLL_DOWN, mpd_widget:command_next_track() },
 			       { "", awesompd.MOUSE_SCROLL_UP, mpd_widget:command_volume_up() },
 			       { "", awesompd.MOUSE_SCROLL_DOWN, mpd_widget:command_volume_down() },
 			       { "", awesompd.MOUSE_RIGHT, mpd_widget:command_show_menu() },
                               { "", "XF86AudioLowerVolume", mpd_widget:command_volume_down() },
                               { "", "XF86AudioRaiseVolume", mpd_widget:command_volume_up() },
                               { modkey, "Pause", mpd_widget:command_playpause() } })
mpd_widget:run()

-- BLING BLING WIDGETS
local blingbling = require("blingbling")
-- SHUTDOWN, REBOOT, LOCK, LOGOUT
shutdown_widget = blingbling.system.shutdownmenu()
reboot_widget = blingbling.system.rebootmenu()
lock_widget = blingbling.system.lockmenu()
logout_widget = blingbling.system.logoutmenu()

blingbling.popups.netstat(netwidget_icon_up,{ title_color = "#444444", established_color= "#111111", listen_color="#777777"})
blingbling.popups.htop(cpuwidget_icon, { terminal = terminal })

-- Create a systray
mysystray = wibox.widget.systray()
-- Create a wibox for each screen and add it
mywibox = {}
mybwibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    --mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", height = beautiful.default_height, screen = s, bg = beautiful.bg_wibar or beautiful.bg_normal })
     
    -- Add widgets to the wibox - order matters
    -- Widgets that are aligned to the left
    local left_wibox = wibox.layout.fixed.horizontal()
    --local tag_bar = rad_tag(s)
    --left_wibox:add(tag_bar._internal.layout)
    left_wibox:add(mylayoutbox[s])
    left_wibox:add(spacer)
    left_wibox:add(mytaglist[s])
    left_wibox:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_wibox = wibox.layout.fixed.horizontal()
    local right_layout_meta = wibox.layout.fixed.horizontal()
    -- TODO: endarrow right_layout_meta
    right_wibox:add(separator)
    right_wibox:add(mytextclock)
    right_wibox:add(separator)
    if s == 1 then right_wibox:add(mysystray) end
    right_wibox:add(separator)
        local right_bg = wibox.widget.background()
    right_bg:set_bg(beautiful.bg_alternate)
    right_bg:set_widget(right_wibox)
    right_layout_meta:add(right_bg)
    
    -- Bringin it all together
    local wibox_layout = wibox.layout.align.horizontal()
    wibox_layout:set_left(left_wibox)
    wibox_layout:set_middle(mytasklist[s])
    wibox_layout:set_right(right_wibox)

    mywibox[s]:set_widget(wibox_layout)

    -- Create the bottom wibox
    mybwibox[s] = awful.wibox({ position = "bottom", screen = s, height = beautiful.default_height, bg = beautiful.bg_wibar or beautiful.bg_normal  })


    -- Add widgets to the wibox - order matters
    local left_bwibox = wibox.layout.fixed.horizontal()
--    left_bwibox:add(myTesttextbox)
    left_bwibox:add(spacer)
    left_bwibox:add(netwidget_icon_down)
    left_bwibox:add(netwidget_icon_up)
    left_bwibox:add(netwidget)
    left_bwibox:add(separator)
    left_bwibox:add(memwidget_icon)
    left_bwibox:add(spacer)
    left_bwibox:add(memwidget)
    left_bwibox:add(separator)
    left_bwibox:add(cpuwidget_icon)
    left_bwibox:add(spacer)
    left_bwibox:add(cpuwidget)
    left_bwibox:add(separator)
    left_bwibox:add(ipwidget)
    left_bwibox:add(separator)
    left_bwibox:add(myTempWidget_icon)
    left_bwibox:add(myTempWidget)
    left_bwibox:add(separator)
    
    local right_bwibox = wibox.layout.fixed.horizontal()
    right_bwibox:add(mpd_widget.widget)
    right_bwibox:add(separator)
    right_bwibox:add(reboot_widget)
    right_bwibox:add(shutdown_widget)
    right_bwibox:add(logout_widget)
    right_bwibox:add(lock_widget)

    
    local bwibox_layout = wibox.layout.align.horizontal()
    bwibox_layout:set_left(left_bwibox)
    bwibox_layout:set_right(right_bwibox)
    mybwibox[s]:set_widget(bwibox_layout)

end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),
    awful.key({ }, "Print", function() awful.util.spawn("capscr", false) end),
    awful.key({ modkey,		  }, "e",      revelation),
    awful.key({ modkey, "Control" }, "l", function() awful.util.spawn("xscreensaver-command -lock") end),

    awful.key({ modkey,           }, "b", function ()  batteryShow("BAT0") end),
    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show({keygrabber=true}) end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),
    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "r",     function ()
	    awful.util.spawn("dmenu_run -i -p 'Run command:' -nb '" .. 
		beautiful.bg_normal .. "' -nf '" .. beautiful.fg_normal .. 
		"' -sb '" .. beautiful.bg_focus .. 
		"' -sf '" .. beautiful.fg_focus .. "'") 	
	end),
    --awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end),
    awful.key({ modkey, }, "i", function()
	    local c = client.focus
	    if not c then
		    return
	    end

	    local geom = c:geometry()
	    local t = ""
	    if c.class then t=t .. "Class: " .. c.class .. "\n" end
	    if c.instance then t=t .. "Instance: " .. c.instance .. "\n" end
	    if c.role then t=t .. "Role: " .. c.role .. "\n" end
	    if c.name then t=t .. "Name: " .. c.name .. "\n" end
	    if c.type then t=t .. "Type: " .. c.type .. "\n" end
	    if geom.width and geom.height and geom.x and geom.y then
		    t = t .. "Dimensions: " .. "x:" .. geom.x .. " y:" .. geom.y .. " w:" .. geom.width .. " h:" .. geom.height
	    end

	    naughty.notify( {
		    text = t,
		    timeout = 30,
	    })
    end)
)


for i = 1, 10 do
	local screen = mouse.screen
	local tag = awful.tag.gettags(screen)[i]
	globalkeys = awful.util.table.join(globalkeys,
		awful.key({ modkey }, "#" .. i + 9,
			function ()
				if tag then
					awful.tag.viewonly(tag)
				end
			end),
		awful.key({ modkey, "Control" }, "#" .. i + 9,
			function ()
				if tag then
					awful.tag.viewtoggle(tag)
				end
			end),
		awful.key({ modkey, "Shift" }, "#" .. i + 9,
			function ()
				if client.focus and tag then
					awful.client.movetotag(tag)
				end
			end),
		awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
			function ()
				if client.focus and tag then
					awful.client.toggletag(tag)
				end
			end))
end
-- Compute the maximum number of digit we need, limited to 9
--keynumber = 0
--for s = 1, screen.count() do
--  keynumber = math.min(9, math.max(#tags[s], keynumber));
--end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
--for i = 1, keynumber do
--    globalkeys = awful.util.table.join(globalkeys,
--        awful.key({ modkey }, "#" .. i + 9,
--                  function ()
--                        local screen = mouse.screen
--                       if tags[screen][i] then
--				awful.tag.viewonly(tags[screen][i])
--                        end
--                  end),
--       awful.key({ modkey, "Control" }, "#" .. i + 9,
--                  function ()
--                      local screen = mouse.screen
--                      if tags[screen][i] then
--                          awful.tag.viewtoggle(tags[screen][i])
--                      end
--                  end),
--        awful.key({ modkey, "Shift" }, "#" .. i + 9,
--                  function ()
--                      if client.focus and tags[client.focus.screen][i] then
--                          awful.client.movetotag(tags[client.focus.screen][i])
--                      end
--                  end),
--        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
--                  function ()
--                      if client.focus and tags[client.focus.screen][i] then
--                          awful.client.toggletag(tags[client.focus.screen][i])
--                      end
--                  end))
--end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
mpd_widget:append_global_keys()
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
--      { rule = { class = "Firefox", instance = "Places" },
  --      properties = {maximized_vertical = false, maximized_horizontal = false} },
--    { rule = { class = "MPlayer" },
--      properties = { floating = true } },
--    { rule = { class = "pinentry" },
--      properties = { floating = true } },
--    { rule = { class = "gimp" },
--      properties = { floating = true } },
--    { rule = { instance = "Plugin-container" },
--      properties = { floating = true } },
--    { rule = { instance = "Firefox" },
--      properties = { tag = tags[1][2] } },
}
-- }}}


-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })
    local cls = c.class
    local inst = c.instance
    local role = c.role
    if cls.class then
 	    if floatapps[role] then
		    awful.client.floating.set(c, floatpps[role])
	    elseif floatapps[cls] then
		    awful.client.floating.set(c, floatapps[cls])                                                    
	    elseif floatapps[inst] then
        	    awful.client.floating.set(c, floatapps[inst])
	    end
    end
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- Timers
ip_timer = timer({timeout = 5})
ip_timer:connect_signal("timeout", function() ipwidget:set_text( "IP: " .. get_ip()) end)
ip_timer:start()

--net_timer = timer({timeout = 5})
--net_timer:connect_signal("timeout", function netwidget.text = get_net_usage() end)
--net_timer:start()

-- RUN ONCE AFTER BOOT
run_once("urxvtd")
run_once("/usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1")
--run_once("dbus-launch nm-applet --sm-disable")
run_once("dropbox")
run_once("nm-applet")
run_once("volumeicon")
run_once("xfce4-power-manager")
run_once("thunar --daemon")
run_once("parcellite")
