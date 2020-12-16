Hooks:PostHook(HUDLootScreenSkirmish, "make_cards", "make_cards_hophud", function (self, peer)
	local peer_id = peer and peer:id() or 1
	local data = self._peer_data[peer_id]
	if not data then
		return
	end
	local name, level, rank, color_id = HopHUD:information_by_peer(peer)
	HopHUD:set_name_panel_text(data.player_text, name, level, rank, color_id)
	data.player_text:set_x(rank > 0 and data.player_infamy:right() or data.player_infamy:left())
end)
