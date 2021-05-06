Hooks:PreHook(HUDManager, "_add_name_label", "_add_name_label_hophud", function (self, data)
	self._add_label_data = {
		movement = data.unit:movement()
	}
end)

Hooks:PreHook(HUDManager, "add_vehicle_name_label", "add_vehicle_name_label_hophud", function (self, data)
	self._add_label_data = {
		vehicle = data.unit,
		character_name = data.name
	}
end)

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
	local data = self._add_label_data
	if not data then
		local id = panel:name():gsub("name_panel", "")
		local data = self:_get_name_label(tonumber(id))
		if not data then
			return
		end
	end
	local name, level, rank, color_id
	if data.vehicle then
		name, level = data.character_name, managers.localization:text("hud_hophud_unit_type_vehicle")
	else
		name, level, rank, color_id = HopHUD:information_by_unit(data.movement._unit)
	end
	local color = tweak_data.chat_colors[color_id] or Color.white

	local text = panel:child("text")
	local action = panel:child("action")
	local bag = panel:child("bag")
	local bag_number = panel:child("bag_number")
	local infamy = panel:child("infamy")

	panel:child("cheater"):set_size(0, 0)

	interact._radius = tweak_data.hud.name_label_font_size
	local double_radius = interact._radius * 2
	interact._circle:set_size(double_radius, double_radius)
	if interact._bg_circle then
		interact._bg_circle:set_size(double_radius, double_radius)
	end
	interact:set_position(0, 0)

	if infamy then
		infamy:set_size(tweak_data.hud.name_label_font_size * (infamy:w() / infamy:h()) * 0.75, tweak_data.hud.name_label_font_size * 0.75)
		infamy:set_lefttop(double_radius + 4, 2)
	end

	local empty = text:text() == ""
	HopHUD:set_name_panel_text(text, name, level, rank, color_id)
	local _, _, tw, th = text:text_rect()
	text:set_size(tw, th)
	if empty then
		text:set_text("")
		text:set_w(0)
	end
	text:set_lefttop(double_radius + 4 + (infamy and infamy:w() or 0), 0)

	local _, _, aw, ah = action:text_rect()
	action:set_size(aw, ah)
	action:set_leftbottom(double_radius + 4, double_radius)
	action:set_color(HopHUD.colors.action)

	bag:set_size(tweak_data.hud.name_label_font_size * (bag:w() / bag:h()) * 0.75, tweak_data.hud.name_label_font_size * 0.75)
	bag:set_lefttop(text:right() + 4, 2)
	bag:set_color(color)

	if bag_number then
		bag_number:set_width(double_radius)
		bag_number:set_lefttop(bag:right() + 4, 1)
		bag_number:set_color(color)
	end

	panel:set_size(math.max((bag_number or bag):right(), action:right()), double_radius)

	self._add_label_data = nil
end

Hooks:PostHook(HUDManager, "set_ai_stopped", "set_ai_stopped_hophud", function (self, ai_id, stopped)
	if not stopped then
		return
	end

	local teammate_panel = self._teammate_panels[ai_id]
	local panel = teammate_panel and teammate_panel._panel
	if not panel then
		return
	end

	local stop_icon = panel:child("stopped")
	local callsign = panel:child("callsign")
	if stop_icon and callsign then
		stop_icon:set_right(callsign:left() - 4)
	end

	local label = nil
	for _, lbl in ipairs(self._hud.name_labels) do
		if lbl.id == ai_id then
			label = lbl
			break
		end
	end
	if label then
		local label_stop_icon = label.panel:child("stopped")
		if label_stop_icon then
			local ratio = label_stop_icon:texture_width() / label_stop_icon:texture_height()
			label_stop_icon:set_size(label.text:h() * ratio, label.text:h())
			label_stop_icon:set_right(label.text:left() - 4)
			label_stop_icon:set_center_y(label.text:center_y() - 1)
		end
	end
end)
