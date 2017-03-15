local _on_damage_received_original = CopDamage._on_damage_received
function CopDamage:_on_damage_received(damage_info, ...)
  if not managers.groupai:state():is_enemy_converted_to_criminal(self._unit) then
    MyHUD:add_damage_pop(self._unit, damage_info)
  end
  return _on_damage_received_original(self, damage_info, ...)
end