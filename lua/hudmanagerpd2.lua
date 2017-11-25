local function adjust_name_label(manager, label, name, level, rank, color_id)

  HopHUD:set_name_panel_text(label.text, name, level, rank, color_id)
  local color = tweak_data.chat_colors[color_id] or Color.white
  
  label.interact:remove()
  label.interact = CircleBitmapGuiObject:new(label.panel, {
    blend_mode = "add",
    use_bg = true,
    layer = 0,
    radius = tweak_data.hud.name_label_font_size,
    color = Color.white
  })
  label.interact:set_visible(false)
  
  local action = label.panel:child("action")
  if action then
    action:set_color(HopHUD.colors.action)
  end
  
  local infamy = label.panel:child("infamy")
  if infamy then
    infamy:set_size(tweak_data.hud.name_label_font_size * 1.25 * (infamy:w() / infamy:h()), tweak_data.hud.name_label_font_size * 1.25)
  end
  
  local bag = label.panel:child("bag")
  if bag then
    bag:set_size(tweak_data.hud.name_label_font_size * (bag:w() / bag:h()) * 0.75, tweak_data.hud.name_label_font_size * 0.75)
    bag:set_color(color)
  end
  
  local bag_number = label.panel:child("bag_number")
  if bag_number then
    bag_number:set_color(color_id and tweak_data.chat_colors[color_id] or Color.white)
    bag_number:set_text("X1")
  end
  
  manager:align_teammate_name_label(label.panel, label.interact)
  
end

local _add_name_label_original = HUDManager._add_name_label
function HUDManager:_add_name_label(data)
  local id = _add_name_label_original(self, data)
  local label = self:_get_name_label(id)
  
  local name, level, rank, color_id = HopHUD:information_by_unit(data.unit)
  adjust_name_label(self, label, name, level, rank, color_id)
  
  return id
end

local add_vehicle_name_label_original = HUDManager.add_vehicle_name_label
function HUDManager:add_vehicle_name_label(data, ...)
  local id = add_vehicle_name_label_original(self, data, ...)
  local label = self:_get_name_label(id)
  
  adjust_name_label(self, label, data.name, "Vehicle", nil, nil)

  return id
end

local add_teammate_panel_original = HUDManager.add_teammate_panel
function HUDManager:add_teammate_panel(character_name, player_name, ai, peer_id)
  local id = add_teammate_panel_original(self, character_name, player_name, ai, peer_id)
  
  local unit = managers.criminals:character_unit_by_name(character_name)
  if unit then
    local _, level, rank, color_id = HopHUD:information_by_unit(unit)
    HopHUD:set_teammate_name_panel(self._teammate_panels[id], player_name, level, rank, color_id)
    HopHUD:create_kill_counter(self._teammate_panels[id], id == HUDManager.PLAYER_PANEL and managers.statistics:session_total_kills())
  end
  
  return id
end