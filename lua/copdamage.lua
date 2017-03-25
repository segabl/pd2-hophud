local _on_damage_received_original = CopDamage._on_damage_received
function CopDamage:_on_damage_received(damage_info, ...)
  local result = _on_damage_received_original(self, damage_info, ...)
  if type(damage_info.damage) == "number" and damage_info.damage > 0 then
    MyHUD:add_damage_pop(self._unit, damage_info)
  end
  return result
end