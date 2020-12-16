Hooks:PostHook(LobbyCharacterData, "update_character", "update_character_hophud", function (self)
	if not self:_can_update() then
		return
	end

	local name, level, rank, color_id = HopHUD:information_by_peer(self._peer)
	HopHUD:set_name_panel_text(self._name_text, name, level, rank, color_id)

	self:sort_text_and_reposition()
end)
