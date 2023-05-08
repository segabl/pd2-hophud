Hooks:PreHook(PlayerManager, "activate_temporary_upgrade", "activate_temporary_upgrade_hophud", function (self, category, upgrade)
	if not HopHUD.settings.display_invulnerability or upgrade ~= "armor_break_invulnerable" and upgrade ~= "mrwi_health_invulnerable" then
		return
	end

	local upgrade_value = self:upgrade_value(category, upgrade)
	if upgrade_value == 0 then
		return
	end

	local teammate_panel = managers.hud:get_teammate_panel_by_peer()
	if teammate_panel then
		teammate_panel:animate_invulnerability(upgrade_value[upgrade == "mrwi_health_invulnerable" and 2 or 1])
	end
end)

Hooks:PostHook(PlayerManager, "add_to_temporary_property", "add_to_temporary_property_hophud", function (self, name)
	if not HopHUD.settings.display_bulletstorm or name ~= "bullet_storm" then
		return
	end

	local bullet_storm = self._temporary_properties._properties[name]
	if not bullet_storm then
		return
	end

	local teammate_panel = managers.hud:get_teammate_panel_by_peer()
	if teammate_panel then
		teammate_panel:animate_bulletstorm(bullet_storm[2] - Application:time())
	end
end)
