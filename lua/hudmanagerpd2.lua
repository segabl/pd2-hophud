local function adjust_name_label(manager, data, label, name, level, rank, color_id)
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
		infamy:set_size(tweak_data.hud.name_label_font_size * (infamy:w() / infamy:h()) * 0.75, tweak_data.hud.name_label_font_size * 0.75)
	end

	local bag = label.panel:child("bag")
	if bag then
		bag:set_size(tweak_data.hud.name_label_font_size * (bag:w() / bag:h()) * 0.75, tweak_data.hud.name_label_font_size * 0.75)
		bag:set_color(color)
	end

	local bag_number = label.panel:child("bag_number")
	if bag_number then
		bag_number:set_color(color_id and tweak_data.chat_colors[color_id] or Color.white)
		bag_number:set_text("X999")
	end

	data.name = label.text:text()

	manager:align_teammate_name_label(label.panel, label.interact)
end

local _add_name_label_original = HUDManager._add_name_label
function HUDManager:_add_name_label(data)
	local id = _add_name_label_original(self, data)
	local label = self:_get_name_label(id)

	local name, level, rank, color_id = HopHUD:information_by_unit(data.unit)
	adjust_name_label(self, data, label, name, level, rank, color_id)

	return id
end

local add_vehicle_name_label_original = HUDManager.add_vehicle_name_label
function HUDManager:add_vehicle_name_label(data, ...)
	local id = add_vehicle_name_label_original(self, data, ...)
	local label = self:_get_name_label(id)

	adjust_name_label(self, data, label, data.name, managers.localization:text("hud_hophud_unit_type_vehicle"), nil, nil)

	return id
end

local add_teammate_panel_original = HUDManager.add_teammate_panel
function HUDManager:add_teammate_panel(character_name, player_name, ai, peer_id)
	local id = add_teammate_panel_original(self, character_name, player_name, ai, peer_id)

	local unit = managers.criminals:character_unit_by_name(character_name)
	if unit then
		local _, _, _, color_id = HopHUD:information_by_unit(unit)
		HopHUD:set_teammate_name_panel(self._teammate_panels[id], player_name, color_id)
	end

	return id
end

function HUDManager:align_teammate_name_label(panel, interact)
	local text = panel:child("text")
	local action = panel:child("action")
	local bag = panel:child("bag")
	local bag_number = panel:child("bag_number")
	local infamy = panel:child("infamy")
	local _, _, tw, th = text:text_rect()
	local _, _, aw, ah = action:text_rect()
	local double_radius = interact:radius() * 2
	local panel_w = double_radius + 4 + math.max(tw + 4 + bag:w(), aw)
	local panel_h = math.max(th + ah, double_radius)

	panel:child("cheater"):set_size(0, 0)

	interact:set_position(0, 0)

	text:set_size(tw, th)
	text:set_position(double_radius + 4, 0)

	action:set_size(aw, ah)
	action:set_position(double_radius + 4, panel_h - ah)

	if infamy then
		infamy:set_x(double_radius + 4)
		infamy:set_center_y(text:center_y() + 2)
		text:move(infamy:w(), 0)
		panel_w = math.max(panel_w, bag:right() + infamy:w())
	end

	bag:set_position(text:right() + 4, text:top() + 2)

	if bag_number then
		local _, _, bw, bh = bag_number:text_rect()
		bag_number:set_size(bw, bh)
		bag_number:set_position(bag:right() + 4, text:top())
		panel_w = math.max(panel_w, bag_number:right())
	end

	panel:set_size(panel_w, panel_h)
	if panel:child("bg") then
		panel:child("bg"):set_position(0, 0)
		panel:child("bg"):set_size(panel:w(), panel:h())
	end
end
