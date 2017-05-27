local init_original = HUDLootScreen.init
function HUDLootScreen:init(hud, workspace, saved_lootdrop, saved_selected, saved_chosen, saved_setup)
  init_original(self, hud, workspace, saved_lootdrop, saved_selected, saved_chosen, saved_setup)

  local local_peer_id = self:get_local_peer_id()
  local panel = self._peers_panel:child("peer" .. tostring(local_peer_id))
  local peer_info_panel = panel:child("peer_info")
  local peer_name = peer_info_panel:child("peer_name")
  
  if not managers.network:session() then
    return
  end
  
  local name, level, rank, _ = NebbyHUD:information_by_peer(managers.network:session():local_peer())
  NebbyHUD:set_name_panel_text(peer_name, name, level, rank)
  
  self:make_fine_text(peer_name)
  peer_name:set_right(peer_info_panel:w())
  if rank then
    peer_info_panel:child("peer_infamy"):set_right(peer_name:x())
    peer_info_panel:child("peer_infamy"):set_top(peer_name:y())
  end
end

local make_cards_original = HUDLootScreen.make_cards
function HUDLootScreen:make_cards(peer, max_pc, left_card, right_card)
  make_cards_original(self, peer, max_pc, left_card, right_card)

  local peer_id = peer and peer:id() or 1
  
  local panel = self._peers_panel:child("peer" .. tostring(peer_id))
  local peer_info_panel = panel:child("peer_info")
  local peer_name = peer_info_panel:child("peer_name")
  
  local name, level, rank, _ = NebbyHUD:information_by_peer(peer)
  NebbyHUD:set_name_panel_text(peer_name, name, level, rank)
  
  self:make_fine_text(peer_name)
  peer_name:set_right(peer_info_panel:w())
  if rank then
    peer_info_panel:child("peer_infamy"):set_right(peer_name:x())
    peer_info_panel:child("peer_infamy"):set_top(peer_name:y())
  end
end
