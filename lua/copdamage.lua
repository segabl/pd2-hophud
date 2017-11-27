local _call_listeners_original = CopDamage._call_listeners
function CopDamage:_call_listeners(damage_info, ...)
  local result = _call_listeners_original(self, damage_info, ...)
  
  if type(damage_info.damage) == "number" and damage_info.damage > 0 then
    HopHUD:add_damage_pop(self._unit, damage_info)
    if self._dead then
      HopHUD:update_kill_counter(damage_info.attacker_unit)
    end
  end
  
  return result
end