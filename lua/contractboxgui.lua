local create_character_text_original = ContractBoxGui.create_character_text
function ContractBoxGui:create_character_text(peer_id, x, y, text, icon)
  create_character_text_original(self, peer_id, x, y, text, icon)
  
  local name, level, rank, _ = NebbyHUD:information_by_peer(managers.network:session():peer(peer_id))
  NebbyHUD:set_name_panel_text(self._peers[peer_id], name, level, rank)

  local _, _, w, h = self._peers[peer_id]:text_rect()
  self._peers[peer_id]:set_size(w, h)
  self._peers[peer_id]:set_center(x, y)
  if self._peers_icon and self._peers_icon[peer_id] then
    self._peers_icon[peer_id]:set_right(self._peers[peer_id]:x())
  end
end
