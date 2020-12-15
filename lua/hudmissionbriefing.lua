Hooks:PostHook(HUDMissionBriefing, "set_player_slot", "set_player_slot_hophud", function (self, nr, params)
	local slot = self._ready_slot_panel:child("slot_" .. tostring(nr))
	if not slot or not alive(slot) then
		return
	end
	HopHUD:set_name_panel_text(slot:child("name"), params.name, params.level, params.rank, nr)
end)
