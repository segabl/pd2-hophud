local _call_listeners_original = CopDamage._call_listeners
function CopDamage:_call_listeners(damage_info, ...)
  if type(damage_info.damage) == "number" and damage_info.damage > 0 then
    HopHUD:add_damage_pop(self._unit, damage_info)
    if self._dead and alive(damage_info.attacker_unit) then
      local attacker = damage_info.attacker_unit
      local attacker = attacker:base()._thrower_unit or attacker
      local panel_id = attacker:base().is_local_player and HUDManager.PLAYER_PANEL
      if not panel_id then
        local criminal_data = managers.criminals:character_data_by_unit(attacker)
        panel_id = criminal_data and criminal_data.panel_id
      end
      if managers.hud._teammate_panels[panel_id] then
        HopHUD:update_kill_counter(managers.hud._teammate_panels[panel_id])
      end
    end
  end
  return _call_listeners_original(self, damage_info, ...)
end