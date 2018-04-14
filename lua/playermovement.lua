local update_stamina_original = PlayerMovement.update_stamina
function PlayerMovement:update_stamina(...)
  update_stamina_original(self, ...)

  local teammate_panel = managers.hud:get_teammate_panel_by_peer()
  if teammate_panel then
    teammate_panel:set_stamina({
      current = self._stamina,
      total = self:_max_stamina()
    })
  end
end