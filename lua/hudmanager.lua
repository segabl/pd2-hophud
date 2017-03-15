local init_finalize_original = HUDManager.init_finalize
function HUDManager:init_finalize(...)
  init_finalize_original(self, ...)
  MyHUD:check_create_panel()
end

function HUDManager:update_name_label_by_peer(peer)
  for _, data in pairs(self._hud.name_labels) do
    if data.peer_id == peer:id() then
      MyHUD:set_name_panel_text(data.text, data.character_name, peer:level(), peer:rank())
      self:align_teammate_name_label(data.panel, data.interact)
    end
  end
end

local reset_player_hpbar_original = HUDManager.reset_player_hpbar
function HUDManager:reset_player_hpbar()
  reset_player_hpbar_original(self)
  local name, level, rank, color_id = MyHUD:information_by_peer(managers.network:session():local_peer())
  MyHUD:set_teammate_name_panel(self._teammate_panels[HUDManager.PLAYER_PANEL], name, level, rank, color_id)
end

local update_original = HUDManager.update
function HUDManager:update(...)
  update_original(self, ...)
  MyHUD:update(...)
end