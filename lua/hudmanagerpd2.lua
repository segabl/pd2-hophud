local _add_name_label_original = HUDManager._add_name_label
function HUDManager:_add_name_label(data)
  local name = data.name
  
  local id = _add_name_label_original(self, data)
  
  local label = self:_get_name_label(id)
  local _, level, rank, _ = MyHUD:information_by_unit(data.unit)
  MyHUD:set_name_panel_text(label.text, name, level, rank)
  label.panel:child("action"):set_color(Color.white:with_alpha(0.8))
  
  self:align_teammate_name_label(label.panel, label.interact)
  
  return id
end

local add_teammate_panel_original = HUDManager.add_teammate_panel
function HUDManager:add_teammate_panel(character_name, player_name, ai, peer_id)
  local id = add_teammate_panel_original(self, character_name, player_name, ai, peer_id)
  
  local unit = managers.criminals:character_unit_by_name(character_name)
  if unit then
    local _, level, rank, color_id = MyHUD:information_by_unit(unit)
    MyHUD:set_teammate_name_panel(self._teammate_panels[id], player_name, level, rank, color_id)
  end
  
  return id
end

local add_vehicle_name_label_original = HUDManager.add_vehicle_name_label
function HUDManager:add_vehicle_name_label(...)
  local id = add_vehicle_name_label_original(self, ...)
  
  local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2)
  local panel = hud.panel:child("name_label" .. id)
  
  panel:child("text"):set_color(Color.white)
  panel:child("bag"):set_color(Color.white)
  panel:child("bag_number"):set_color(Color.white)
  panel:child("action"):set_color(Color.white:with_alpha(0.8))
  
  return id
end