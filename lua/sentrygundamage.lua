local _apply_damage_original = SentryGunDamage._apply_damage
function SentryGunDamage:_apply_damage(damage, dmg_shield, dmg_body, is_local, attacker_unit, ...)
  local result = _apply_damage_original(self, damage, dmg_shield, dmg_body, is_local, attacker_unit, ...)
  if damage and type(damage) == "number" and damage > 0 then
    MyHUD:add_damage_pop(self._unit, { attacker_unit = attacker_unit, damage = damage })
  end
  return result
end