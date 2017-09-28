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
  NebbyHUD:create_kill_counter(self._teammate_panels[HUDManager.PLAYER_PANEL])
end

local update_original = HUDManager.update
function HUDManager:update(...)
  update_original(self, ...)
  NebbyHUD:update(...)
end

function HUDManager:update_vehicle_label_by_id(label_id, num_players)
  for _, data in pairs(self._hud.name_labels) do
    if data.id == label_id then
      local vehicle_text = "Vehicle " .. data.character_name
      local text = data.text
      text:set_text(vehicle_text)
      local _, _, v_w, _ = text:text_rect()
      local color_ranges = {
        { 0, 7, NebbyHUD.colors.level }
      }
      local vehicle_ext = alive(data.vehicle) and data.vehicle:vehicle_driving()
      if vehicle_ext then
        for _, v in pairs(vehicle_ext._seats) do
          local name, level, rank, color_id = NebbyHUD:information_by_unit(v.occupant)
          if name then
            local rank_string, level_string = NebbyHUD:rank_and_level_string(rank, level)
            local name_string = rank_string .. level_string .. " " .. name
            local prev_len = utf8.len(vehicle_text) + 1
            vehicle_text = vehicle_text .. "\n" .. name_string
            if color_id and tweak_data.chat_colors[color_id] then
              table.insert(color_ranges, { prev_len + utf8.len(rank_string .. level_string), prev_len + utf8.len(name_string), tweak_data.chat_colors[color_id] })
            end
            table.insert(color_ranges, { prev_len, prev_len + utf8.len(rank_string), NebbyHUD.colors.rank })
            table.insert(color_ranges, { prev_len + utf8.len(rank_string), prev_len + utf8.len(rank_string .. level_string), NebbyHUD.colors.level })
          end
        end
      end
      text:set_text(vehicle_text)
      text:set_color(Color.white)
      for _, v in ipairs(color_ranges) do
        text:set_range_color(unpack(v))
      end
      self:align_teammate_name_label(data.panel, data.interact)
      data.bag:set_x(text:left() + v_w + 4)
      data.bag:set_top(text:top() + 3)
      data.bag_number:set_x(data.bag:left() + data.bag:w() + 4)
      data.bag_number:set_top(data.bag:top())
      break
    end
  end
end