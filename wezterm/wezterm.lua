--
-- ██╗    ██╗███████╗███████╗████████╗███████╗██████╗ ███╗   ███╗
-- ██║    ██║██╔════╝╚══███╔╝╚══██╔══╝██╔════╝██╔══██╗████╗ ████║
-- ██║ █╗ ██║█████╗    ███╔╝    ██║   █████╗  ██████╔╝██╔████╔██║
-- ██║███╗██║██╔══╝   ███╔╝     ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║
-- ╚███╔███╔╝███████╗███████╗   ██║   ███████╗██║  ██║██║ ╚═╝ ██║
--  ╚══╝╚══╝ ╚══════╝╚══════╝   ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝
-- A GPU-accelerated cross-platform terminal emulator
-- https://wezfurlong.org/wezterm/

local wezterm = require("wezterm")
local act = wezterm.action

wezterm.on("toggle-opacity", function(window, pane)
	local overrides = window:get_config_overrides() or {}
	if not overrides.window_background_opacity then
		overrides.window_background_opacity = 0.5
	else
		overrides = {}
	end
	window:set_config_overrides(overrides)
end)

local function dark_schemes()
	local schemes = wezterm.color.get_builtin_schemes()
	local dark = {}
	for name, scheme in pairs(schemes) do
		-- parse into a color object
		if not (scheme.background == nil) then
			local bg = wezterm.color.parse(scheme.background)
			-- and extract HSLA information
			local h, s, l, a = bg:hsla()

			-- `l` is the "lightness" of the color where 0 is darkest
			-- and 1 is lightest.
			if l < 0.2 then
				table.insert(dark, name)
			end
		end
	end

	table.sort(dark)
	return dark
end

local dark = dark_schemes()

wezterm.on("window-config-reloaded", function(window, pane)
	window:toast_notification("wezterm", "configuration reloaded ", nil, 500)
end)

wezterm.on("gui-startup", function(cmd)
	local tab, pane, window = wezterm.mux.spawn_window(cmd or {})
	window:gui_window():maximize()
end)

local SOLID_LEFT_ARROW = wezterm.nerdfonts.ple_left_half_circle_thick
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.ple_right_half_circle_thick

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local colors = config.resolved_palette.tab_bar
	local state = tab.is_active and "active_tab" or "inactive_tab"
	local background = colors[state].bg_color
	local foreground = colors[state].fg_color

	local edge_background = colors.background
	local edge_foreground = background

	-- ensure that the titles fit in the available space,
	-- and that we have room for the edges.
	local title = wezterm.truncate_right(tab.active_pane.title, max_width - 2)

	return {
		{ Background = { Color = edge_background } },
		{ Foreground = { Color = edge_foreground } },
		{ Text = " " .. SOLID_LEFT_ARROW },
		{ Background = { Color = background } },
		{ Foreground = { Color = foreground } },
		{ Text = title },
		{ Background = { Color = edge_background } },
		{ Foreground = { Color = edge_foreground } },
		{ Text = SOLID_RIGHT_ARROW .. " " },
	}
end)

wezterm.on("update-right-status", function(window)
	window:set_right_status(window:active_workspace())
end)

-- leader key bindings (tmux prefix replacement)
local function leader_key(key, action)
	return { key = key, mods = "LEADER", action = action }
end

local function is_vim(pane)
	-- this is set by the plugin, and unset on ExitPre in Neovim
	return pane:get_user_vars().IS_NVIM == "true"
end

local direction_keys = {
	h = "Left",
	j = "Down",
	k = "Up",
	l = "Right",
}

local function split_nav(resize_or_move, key)
	local mods = resize_or_move == "resize" and "CTRL|SHIFT" or "CTRL"

	return {
		key = key,
		mods = mods,
		action = wezterm.action_callback(function(win, pane)
			if is_vim(pane) then
				-- pass the keys through to vim/nvim
				win:perform_action({
					SendKey = { key = key, mods = mods },
				}, pane)
			else
				if resize_or_move == "resize" then
					win:perform_action({ AdjustPaneSize = { direction_keys[key], 3 } }, pane)
				else
					win:perform_action({ ActivatePaneDirection = direction_keys[key] }, pane)
				end
			end
		end),
	}
end

return {
	font = wezterm.font({
		family = "JetBrains Mono",
	}),
	font_size = 16.0,
	color_scheme = "Catppuccin Mocha",
	enable_scroll_bar = false,
	enable_tab_bar = true,
	use_fancy_tab_bar = false,
	tab_bar_at_bottom = true,
	show_new_tab_button_in_tab_bar = false,
	-- hide_tab_bar_if_only_one_tab = true,

	-- window_background_image = os.getenv("HOME") .. "/Pictures/Background/blob_blue.gif",
	-- window_background_image_hsb = {
	-- 	brightness = 0.1,
	-- 	saturation = 1.0,
	-- },

	ssh_domains = {
		{
			-- This name identifies the domain
			name = "gtr",
			-- The hostname or address to connect to. Will be used to match settings
			-- from your ssh config file
			remote_address = "192.168.0.196",
			-- The username to use on the remote host
			username = "diegodorado",
			remote_wezterm_path = "/home/diegodorado/.nix-profile/bin/wezterm",
		},
	},

	colors = {
		tab_bar = {
			background = "rgba(0,0,0,0)",
		},
	},

	window_padding = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0,
	},
	window_close_confirmation = "NeverPrompt",
	window_decorations = "RESIZE",

	-- timeout_milliseconds defaults to 1000 and can be omitted
	leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 },

	launch_menu = {
		{
			args = { "top" },
		},
		{
			-- Optional label to show in the launcher. If omitted, a label
			-- is derived from the `args`
			label = "Bash",
			-- The argument array to spawn.  If omitted the default program
			-- will be used as described in the documentation above
			args = { "bash", "-l" },

			-- You can specify an alternative current working directory;
			-- if you don't specify one then a default based on the OSC 7
			-- escape sequence will be used (see the Shell Integration
			-- docs), falling back to the home directory.
			-- cwd = "/some/path"

			-- You can override environment variables just for this command
			-- by setting this here.  It has the same semantics as the main
			-- set_environment_variables configuration option described above
			-- set_environment_variables = { FOO = "bar" },
		},
	},

	keys = {
		leader_key("c", act.SpawnTab("CurrentPaneDomain")),
		leader_key("-", act.SplitVertical({ domain = "CurrentPaneDomain" })),
		leader_key("\\", act.SplitHorizontal({ domain = "CurrentPaneDomain" })),
		leader_key("n", act.ActivateTabRelative(1)),
		leader_key("z", act.TogglePaneZoomState),
		leader_key("j", act.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" })),
		leader_key("J", act.ShowLauncher),
		leader_key("l", act.SwitchWorkspaceRelative(1)),
		leader_key("h", act.SwitchWorkspaceRelative(-1)),

		{
			key = "r",
			mods = "LEADER",
			action = wezterm.action_callback(function(window, pane, line)
				local scheme = dark[math.random(#dark)]
				window:set_config_overrides({
					color_scheme = scheme,
				})

				window:toast_notification("wezterm", "configuration reloaded " .. window:window_id(), nil, 500)
			end),
		},

		-- move between split panes
		split_nav("move", "h"),
		split_nav("move", "j"),
		split_nav("move", "k"),
		split_nav("move", "l"),
		-- resize panes
		split_nav("resize", "h"),
		split_nav("resize", "j"),
		split_nav("resize", "k"),
		split_nav("resize", "l"),
		{
			key = "o",
			mods = "CTRL",
			action = act.ActivateCommandPalette,
		},
		{
			key = "r",
			mods = "CTRL|SHIFT",
			action = act.ReloadConfiguration,
		},
		{ key = "d", mods = "SHIFT|CTRL", action = "ShowDebugOverlay" },
		{ key = "n", mods = "SHIFT|CTRL", action = "ToggleFullScreen" },
		{
			key = "B",
			mods = "SHIFT|CTRL",
			action = act.EmitEvent("toggle-opacity"),
		},
	},
}
