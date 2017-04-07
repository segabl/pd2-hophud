local update_character_original = LobbyCharacterData.update_character
function LobbyCharacterData:update_character(...)
  update_character_original(self, ...)

  if not self:_can_update() then
		return
	end
  
  local name, level, rank, color_id = MyHUD:information_by_peer(self._peer)
  MyHUD:set_name_panel_text(self._name_text, name, level, rank, color_id)

	self:sort_text_and_reposition()
end