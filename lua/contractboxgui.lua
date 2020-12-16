Hooks:PostHook(ContractBoxGui, "create_character_text", "create_character_text_hophud", function (self, peer_id, x, y)
	local name, level, rank, color_id = HopHUD:information_by_peer(managers.network:session():peer(peer_id))
	HopHUD:set_name_panel_text(self._peers[peer_id], name, level, rank, color_id)

	local _, _, w, h = self._peers[peer_id]:text_rect()
	self._peers[peer_id]:set_size(w, h)
	self._peers[peer_id]:set_center(x, y)
	if self._peers_icon and self._peers_icon[peer_id] then
		self._peers_icon[peer_id]:set_right(self._peers[peer_id]:x())
	end
end)
