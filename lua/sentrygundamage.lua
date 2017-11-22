local _apply_damage_original = SentryGunDamage._apply_damage
function SentryGunDamage:_apply_damage(damage, dmg_shield, dmg_body, is_local, attacker_unit, ...)
  local result = _apply_damage_original(self, damage, dmg_shield, dmg_body, is_local, attacker_unit, ...)
  if type(damage) == "number" and damage > 0 then
    local pos = self._unit:position()
    HopHUD:add_damage_pop(self._unit, { attacker_unit = attacker_unit, damage = damage, pos = Vector3(pos.x, pos.y, pos.z + 80) })
  end
  return result
end