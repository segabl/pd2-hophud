local set_player_slot_original = HUDMissionBriefing.set_player_slot
function HUDMissionBriefing:set_player_slot(nr, params)
  set_player_slot_original(self, nr, params)
  local slot = self._ready_slot_panel:child("slot_" .. tostring(nr))
  if not slot or not alive(slot) then
    return
  end
  MyHUD:set_name_panel_text(slot:child("name"), params.name, params.level, params.rank)
end