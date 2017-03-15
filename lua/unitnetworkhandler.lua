local mark_minion_original = UnitNetworkHandler.mark_minion
function UnitNetworkHandler:mark_minion(unit, owner_id, ...)
  mark_minion_original(self, unit, owner_id, ...)
  if alive(unit) and unit:in_slot(16) then
    unit:contour():change_color("friendly", tweak_data.peer_vector_colors[owner_id] or tweak_data.contour.character.friendly_color)
  end
end