Hooks:PostHook(HUDLootScreen, "make_cards", "make_cards_hophud", function (self, peer)
	local peer_id = peer and peer:id() or 1

	local panel = self._peers_panel:child("peer" .. tostring(peer_id))
	local peer_info_panel = panel:child("peer_info")
	local peer_name = peer_info_panel:child("peer_name")

	local name, level, rank, color_id = HopHUD:information_by_peer(peer)
	HopHUD:set_name_panel_text(peer_name, name, level, rank, color_id)

	self:make_fine_text(peer_name)
	peer_name:set_right(peer_info_panel:w())
	peer_info_panel:child("peer_infamy"):set_right(peer_name:x())
end)
