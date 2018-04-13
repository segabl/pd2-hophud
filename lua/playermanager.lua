local activate_temporary_upgrade_original = PlayerManager.activate_temporary_upgrade
function PlayerManager:activate_temporary_upgrade(category, upgrade, ...)

  if upgrade == "armor_break_invulnerable" then
    local upgrade_value = self:upgrade_value(category, upgrade)
    if upgrade_value == 0 then
      return
    end
    local teammate_panel = managers.hud:get_teammate_panel_by_peer()
    if teammate_panel then
      teammate_panel:animate_invulnerability(upgrade_value[1])
    end
  end
  
  return activate_temporary_upgrade_original(self, category, upgrade, ...)
end