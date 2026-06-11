local ok, color = pcall(require, ".config.colors")
if not ok then
	color = {
		primary = "#76946a",
		on_primary = "#1f1f28",
		secondary = "#c0a36e",
		on_secondary = "#1f1f28",
		tertiary = "#7e9cd8",
		on_tertiary = "#1f1f28",
		error = "#c34043",
		on_error = "#1f1f28",
		surface = "#1f1f28",
		on_surface = "#c8c093",
		surface_variant = "#2a2a37",
		on_surface_variant = "#717c7c",
		outline = "#363646",
		shadow = "#1f1f28",
		hover = "#7e9cd8",
		on_hover = "#1f1f28",
	}
end

hl.config({
	general = {
		gaps_in = 5,
		gaps_out = 10,

		border_size = 2,

		col = {
			active_border = color.outline,
			inactive_border = color.shadow,
		},

		resize_on_border = false,
		layout = "scrolling",
	},
	scrolling = {
		column_width = 0.7,
		focus_fit_method = 0,
		fullscreen_on_one_column = false,
	},
	group = {
		auto_group = false,

		col = {
			border_active = color.outline,
			border_inactive = color.shadow,
		},

		groupbar = {
			enabled = true,
			render_titles = true,
			gradients = true,

			gaps_in = 2,
			gaps_out = 2,

			col = {
				active = color.outline,
				inactive = color.shadow,
			},
			text_color = color.on_surface,
			height = 12,
			font_size = 12,
		},
	},

	binds = {
		workspace_back_and_forth = false,
		allow_workspace_cycles = false,
		movefocus_cycles_fullscreen = false,
		workspace_center_on = 1,
	},
	misc = {
		force_default_wallpaper = 0,
		disable_hyprland_logo = true,
		disable_splash_rendering = true,
		vrr = 3,
	},

	decoration = {
		active_opacity = 1,
		inactive_opacity = 0.95,

		rounding = 4,
		rounding_power = 4,

		dim_inactive = true,
		dim_strength = 0.0,
		dim_around = 0.2,
		dim_special = 0.4,

		blur = {
			enabled = true,
			size = 1,
			passes = 0,
			vibrancy = 0.1696,
			xray = true,
		},
	},

	animations = {
		enabled = true,
		workspace_wraparound = true,
	},
})

hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 3, bezier = "almostLinear", style = "slide" })
-- hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 1.21, bezier = "almostLinear", style = "slidevert" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.21, bezier = "almostLinear", style = "slidevert" })
