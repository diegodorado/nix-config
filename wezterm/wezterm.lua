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

wezterm.on("window-config-reloaded", function(window, pane)
	window:toast_notification("wezterm", "configuration reloadedlll!", nil, 4000)
end)

wezterm.on("gui-startup", function(cmd)
	local tab, pane, window = wezterm.mux.spawn_window(cmd or {})
	window:gui_window():maximize()
end)

-- The filled in variant of the < symbol
local SOLID_LEFT_ARROW = wezterm.nerdfonts.ple_left_half_circle_thick
-- The filled in variant of the > symbol
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.ple_right_half_circle_thick

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local edge_background = "rgb(0,0,0,0)"
	local background = "#1b1032"
	local foreground = "#808080"

	if tab.is_active then
		background = "#2b2042"
		foreground = "#c0c0c0"
	end

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
		-- { Text = " " .. title .. " " },
		{ Text = title },
		{ Background = { Color = edge_background } },
		{ Foreground = { Color = edge_foreground } },
		{ Text = SOLID_RIGHT_ARROW .. " " },
	}
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
	-- enable_tab_bar = false,
	enable_tab_bar = true,
	-- use_fancy_tab_bar = true,
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
			-- The color of the strip that goes along the top of the window
			-- (does not apply when fancy tab bar is in use)
			background = "rgba(0,0,0,0)",

			active_tab = {
				bg_color = "#007777",
				fg_color = "#c0c0c0",
			},

			inactive_tab = {
				bg_color = "#1b1032",
				fg_color = "#808080",
			},
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

	keys = {
		leader_key("c", act.SpawnTab("CurrentPaneDomain")),
		leader_key("-", act.SplitVertical({ domain = "CurrentPaneDomain" })),
		leader_key("\\", act.SplitHorizontal({ domain = "CurrentPaneDomain" })),
		leader_key("n", act.ActivateTabRelative(1)),
		leader_key("z", act.TogglePaneZoomState),

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
		-- { key = "l", mods = "SHIFT|CTRL", action = "ShowDebugOverlay" },
		{ key = "n", mods = "SHIFT|CTRL", action = "ToggleFullScreen" },
		{
			key = "B",
			mods = "SHIFT|CTRL",
			action = act.EmitEvent("toggle-opacity"),
		},
	},
}
