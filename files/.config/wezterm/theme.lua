local wezterm = require("wezterm")

function scheme_for_appearance(appearance)
	if appearance:find("Dark") then
		-- return "Builtin Solarized Dark"
		-- return "Afterglow"
		return "BlulocoDark"
	else
		-- return "Builtin Solarized Light"
		return "BlulocoLight"
	end
end

wezterm.on("window-config-reloaded", function(window, pane)
	local overrides = window:get_config_overrides() or {}
	local appearance = window:get_appearance()
	local scheme = scheme_for_appearance(appearance)
	if overrides.color_scheme ~= scheme then
		overrides.color_scheme = scheme
		window:set_config_overrides(overrides)
	end
end)

return {}
