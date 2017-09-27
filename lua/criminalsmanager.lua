function CriminalsManager:_first_free_color_id()
  local taken_ids = {}
  for _, peer in pairs(LuaNetworking:GetPeers()) do
    taken_ids[peer:id()] = true
  end
  for id, data in pairs(self._characters) do
    if data.unit and data.taken and alive(data.unit) then
      if data.peer_id or data.color_id then
        taken_ids[data.peer_id or data.color_id] = true
      end
    end
  end
  for i = CriminalsManager.MAX_NR_CRIMINALS, 1, -1 do
    if not taken_ids[i] then
      return i
    end
  end
  return 5
end

local character_color_id_by_unit_original = CriminalsManager.character_color_id_by_unit
function CriminalsManager:character_color_id_by_unit(unit)
  local search_key = unit:key()
  for id, data in pairs(self._characters) do
    if data.unit and data.taken and search_key == data.unit:key() then
      if data.peer_id and data.peer_id > 0 and (LuaNetworking:IsHost() or not data.data.ai) then
        data.color_id = data.peer_id
      end
      data.color_id = data.color_id or self:_first_free_color_id()
      return data.color_id
    end
  end
  return character_color_id_by_unit_original(self, unit)
end

local _remove_original = CriminalsManager._remove
function CriminalsManager:_remove(id, ...)
  local data = self._characters[id]
  local panel_id = data.name == self._local_character and HUDManager.PLAYER_PANEL or data.data.panel_id
  if panel_id then
    NebbyHUD:update_kill_counter(managers.hud._teammate_panels[panel_id], 0)
  end
  return _remove_original(self, id, ...)
end