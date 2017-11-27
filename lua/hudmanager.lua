local init_finalize_original = HUDManager.init_finalize
function HUDManager:init_finalize(...)
  init_finalize_original(self, ...)
  HopHUD:init()
end

function HUDManager:update_name_label_by_peer(peer)
  for _, data in pairs(self._hud.name_labels) do
    if data.peer_id == peer:id() then
      local name, level, rank, color_id = HopHUD:information_by_peer(peer)
      HopHUD:set_name_panel_text(data.text, name, level, rank, color_id)
      self:align_teammate_name_label(data.panel, data.interact)
    end
  end
end

local reset_player_hpbar_original = HUDManager.reset_player_hpbar
function HUDManager:reset_player_hpbar()
  reset_player_hpbar_original(self)
  local name, level, rank, color_id = HopHUD:information_by_peer(managers.network:session():local_peer())
  HopHUD:set_teammate_name_panel(self._teammate_panels[HUDManager.PLAYER_PANEL], name, level, rank, color_id)
  HopHUD:create_kill_counter(self._teammate_panels[HUDManager.PLAYER_PANEL], managers.statistics:session_total_kills())
end

local update_original = HUDManager.update
function HUDManager:update(...)
  update_original(self, ...)
  HopHUD:update(...)
end

function HUDManager:update_vehicle_label_by_id(label_id)
  local label = self:_get_name_label(label_id)
  if not label then
    return
  end
  
  local occupants_text = ""
  local color_ranges = {}
  local vehicle_ext = alive(label.vehicle) and label.vehicle:vehicle_driving()
  if vehicle_ext then
    for _, v in pairs(vehicle_ext._seats) do
      local name, level, rank, color_id = HopHUD:information_by_unit(v.occupant)
      if name then
        local rank_string, level_string = HopHUD:rank_and_level_string(rank, level)
        local name_string = rank_string .. level_string .. " " .. name
        local prev_len = utf8.len(occupants_text)
        occupants_text = occupants_text .. name_string .. "\n"
        if tweak_data.chat_colors[color_id] then
          table.insert(color_ranges, { prev_len + utf8.len(rank_string .. level_string), prev_len + utf8.len(name_string), tweak_data.chat_colors[color_id] })
        end
        table.insert(color_ranges, { prev_len, prev_len + utf8.len(rank_string), HopHUD.colors.rank })
        table.insert(color_ranges, { prev_len + utf8.len(rank_string), prev_len + utf8.len(rank_string .. level_string), HopHUD.colors.level })
      end
    end
  end
  local action = label.panel:child("action")
  action:set_visible(occupants_text ~= "")
  action:set_text(occupants_text)
  action:set_color(HopHUD.colors.default)
  for _, v in ipairs(color_ranges) do
    action:set_range_color(unpack(v))
  end
  self:align_teammate_name_label(label.panel, label.interact)

end

local _update_name_labels_original = HUDManager._update_name_labels
function HUDManager:_update_name_labels(...)
  _update_name_labels_original(self, ...)

  local half_w, half_h
  for _, data in ipairs(self._hud.name_labels) do
    local label_panel = data.panel
    if label_panel:visible() then
      label_panel:set_x(label_panel:x() + label_panel:w() / 2 - label_panel:child("text"):center_x())
    end
  end
  
end