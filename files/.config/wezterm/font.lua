local wezterm = require("wezterm")

return {
	font = wezterm.font_with_fallback({
		"Cartograph CF",
		-- "Monolisa",
		--[[ "FiraCode NF", ]]
		--[[ "FiraCode Nerd Font", ]]
		--[[ "Iosevka", ]]
		--[[ { family = 'JetBrains Mono', weight = 'Medium' }, ]]
		--[[ {family="Iosevka Term SS05", weight = "Regular" }, ]]
		"Hack Nerd Font", -- nerd fonts extracted from there
		-- "Symbols Nerd Font Mono",
		"SF Pro",
		-- "DejaVu Sans Mono",
		-- "ComicMono NF",
		-- "Victor Mono",
		-- "Liga SFMono Nerd Font",
	}),
	font_size = 12.6,
	-- line_height = 0.91,
	line_height = 0.99,
	-- cell_width = 1.0,
}
