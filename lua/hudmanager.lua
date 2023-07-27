Hooks:PostHook(HUDManager, "init_finalize", "init_finalize_hophud", function ()
	HopHUD:init()
end)

local mask_off_hud = Idstring("guis/mask_off_hud")
Hooks:PostHook(HUDManager, "show", "show_hophud", function (self, name)
	if name == mask_off_hud and self:alive("guis/mask_off_hud") then
		local mask_on_text = self:script("guis/mask_off_hud").mask_on_text
		mask_on_text:set_top(56)
		mask_on_text:set_font_size(tweak_data.hud.name_label_font_size)
	end
end)

function HUDManager:update_name_label_by_peer(peer)
	for _, data in pairs(self._hud.name_labels) do
		if data.peer_id == peer:id() then
			local name, level, rank, color_id = HopHUD:information_by_peer(peer)
			HopHUD:set_name_panel_text(data.text, name, level, rank, color_id)
			self:align_teammate_name_label(data.panel, data.interact)
		end
	end
end

Hooks:PostHook(HUDManager, "reset_player_hpbar", "reset_player_hpbar_hophud", function (self)
	local name, _, _, color_id = HopHUD:information_by_peer(managers.network:session():local_peer())
	HopHUD:set_teammate_name_panel(self._teammate_panels[HUDManager.PLAYER_PANEL], name, color_id)
end)

Hooks:PostHook(HUDManager, "update", "update_hophud", function (self, ...)
	HopHUD:update(...)
end)

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
				if occupants_text ~= "" then
					occupants_text = occupants_text .. ", "
				end

				local prev_len = utf8.len(occupants_text)
				occupants_text = occupants_text .. name

				table.insert(color_ranges, {
					start = prev_len,
					stop = utf8.len(occupants_text),
					color = tweak_data.chat_colors[color_id] or HopHUD.colors.default
				})
			end
		end
	end

	if HopHUD.settings.uppercase_names then
		occupants_text = occupants_text:upper()
	end

	local action = label.panel:child("action")
	action:set_visible(occupants_text ~= "")
	action:set_text(occupants_text)
	action:set_color(HopHUD.colors.default)
	for _, c in pairs(color_ranges) do
		action:set_range_color(c.start, c.stop, c.color)
	end

	self:align_teammate_name_label(label.panel, label.interact)
end

Hooks:PostHook(HUDManager, "_update_name_labels", "_update_name_labels_hophud", function (self)
	for _, data in ipairs(self._hud.name_labels) do
		local label_panel = data.panel
		if label_panel:visible() then
			label_panel:set_x(label_panel:x() + label_panel:w() / 2 - label_panel:child("text"):center_x())
		end
	end
end)
