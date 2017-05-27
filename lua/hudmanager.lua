local init_finalize_original = HUDManager.init_finalize
function HUDManager:init_finalize(...)
  init_finalize_original(self, ...)
  NebbyHUD:init()
end

function HUDManager:update_name_label_by_peer(peer)
  for _, data in pairs(self._hud.name_labels) do
    if data.peer_id == peer:id() then
      NebbyHUD:set_name_panel_text(data.text, data.character_name, peer:level(), peer:rank())
      self:align_teammate_name_label(data.panel, data.interact)
    end
  end
end

local reset_player_hpbar_original = HUDManager.reset_player_hpbar
function HUDManager:reset_player_hpbar()
  reset_player_hpbar_original(self)
  local name, level, rank, color_id = NebbyHUD:information_by_peer(managers.network:session():local_peer())
  NebbyHUD:set_teammate_name_panel(self._teammate_panels[HUDManager.PLAYER_PANEL], name, level, rank, color_id)
end

local update_original = HUDManager.update
function HUDManager:update(...)
  update_original(self, ...)
  NebbyHUD:update(...)
end