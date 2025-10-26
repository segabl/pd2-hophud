if not HopHUD.settings.main_menu_panel then
	return
end

PlayerProfileGuiObject.BOTTOM_OFFSET = HopHUD.settings.hide_news_feed and 40 or 80

function PlayerProfileGuiObject:init(ws)
	local panel = ws:panel():panel()
	local panel_width = 342
	local font = tweak_data.menu.pd2_medium_font
	local font_size = tweak_data.menu.pd2_small_font_size
	local panel_padding = 12

	-- Add background blur
	panel:rect({
		name = "background",
		color = Color.black,
		alpha = 0.4,
		layer = -1,
		halign = "scale",
		valign = "scale"
	})
	panel:bitmap({
		texture = "guis/textures/test_blur_df",
		w = panel:w(),
		h = panel:h(),
		render_template = "VertexColorTexturedBlur3D",
		layer = -1,
		halign = "scale",
		valign = "scale"
	})

	local avatar_panel = panel:bitmap({
		texture = "guis/textures/pd2/none_icon",
		y = panel_padding,
		x = panel_padding,
		layer = 1,
		w = font_size * 3,
		h = font_size * 3
	})

	local large_avatar
	if Steam then
		Steam:friend_avatar(Steam.MEDIUM_AVATAR, Steam:userid(), function (texture)
			if not large_avatar and alive(avatar_panel) then
				avatar_panel:set_image(texture)
			end
		end)

		Steam:friend_avatar(Steam.LARGE_AVATAR, Steam:userid(), function (texture)
			if alive(avatar_panel) then
				large_avatar = true
				avatar_panel:set_image(texture)
			end
		end)
	end

	local avatar_left = math.round(avatar_panel:right() + panel_padding)
	local perk_icon_size = font_size * 3

	local player_text = panel:text({
		x = avatar_left,
		y = panel_padding,
		font = font,
		font_size = font_size,
		text = "",
		color = tweak_data.screen_colors.text
	})
	HopHUD:set_name_panel_text(player_text, managers.network.account:username() or managers.blackmarket:get_preferred_character_real_name(), managers.experience:current_level(), managers.experience:current_rank(), nil)
	self:_make_fine_text(player_text)
	panel_width = math.max(panel_width, player_text:right() + panel_padding * 2 + perk_icon_size)

	local spec = managers.skilltree:get_specialization_value("current_specialization")
	local perk_text = panel:text({
		x = avatar_left,
		y = math.round(player_text:bottom()),
		text = self:get_text(tostring(tweak_data.skilltree.specializations[spec].name_id)),
		font_size = font_size,
		font = font,
		color = tweak_data.screen_colors.text:with_alpha(0.65)
	})
	self:_make_fine_text(perk_text)
	panel_width = math.max(panel_width, perk_text:right() + panel_padding * 2 + perk_icon_size)

	local next_level_data = managers.experience:next_level_data() or {}
	local current_xp = next_level_data.current_points or 1
	local next_xp = next_level_data.points or 1
	local exp_text = panel:text({
		x = avatar_left,
		y = math.round(perk_text:bottom()),
		text = managers.localization:to_upper_text(next_xp == current_xp and "menu_hophud_max_level_reached" or "menu_hophud_exp_to_next_level", { EXP = managers.money:add_decimal_marks_to_string(tostring(next_xp - current_xp)), LEVEL = tostring(managers.experience:current_level() + 1) }),
		font_size = font_size,
		font = font,
		color = tweak_data.screen_colors.text:with_alpha(0.65)
	})
	self:_make_fine_text(exp_text)
	panel_width = math.max(panel_width, exp_text:right() + panel_padding * 2 + perk_icon_size)

	local money_text = panel:text({
		x = panel_padding,
		y = math.round(avatar_panel:bottom() + panel_padding),
		text = managers.localization:to_upper_text("menu_hophud_spending_cash"),
		font_size = font_size,
		font = font,
		color = tweak_data.screen_colors.text
	})
	self:_make_fine_text(money_text)

	local money_cash_text = panel:text({
		x = panel_padding,
		y = math.round(exp_text:bottom() + font_size * 0.5),
		text = managers.money:total_string(),
		font_size = font_size,
		font = font,
		color = tweak_data.screen_colors.text:with_alpha(0.65)
	})
	self:_make_fine_text(money_cash_text)
	money_cash_text:set_right(panel_width - panel_padding)

	local offshore_text = panel:text({
		x = panel_padding,
		y = math.round(money_text:bottom()),
		text = managers.localization:to_upper_text("hud_offshore_account"),
		font_size = font_size,
		font = font,
		color = tweak_data.screen_colors.text
	})
	self:_make_fine_text(offshore_text)

	local offshore_cash_text = panel:text({
		y = math.round(money_text:bottom()),
		text = managers.experience:cash_string(managers.money:offshore()),
		font_size = font_size,
		font = font,
		color = tweak_data.screen_colors.text:with_alpha(0.65)
	})
	self:_make_fine_text(offshore_cash_text)
	offshore_cash_text:set_right(panel_width - panel_padding)

	local continental_text = panel:text({
		x = panel_padding,
		y = math.round(offshore_text:bottom()),
		text = managers.localization:to_upper_text("menu_es_coins_progress"),
		font_size = font_size,
		font = font,
		color = tweak_data.screen_colors.text
	})
	self:_make_fine_text(continental_text)

	local continental_coins_text = panel:text({
		y = math.round(offshore_text:bottom()),
		text = managers.experience:cash_string(math.floor(math.floor(managers.custom_safehouse:coins())), ""),
		font_size = font_size,
		font = font,
		color = tweak_data.screen_colors.text:with_alpha(0.65)
	})
	self:_make_fine_text(continental_coins_text)
	continental_coins_text:set_right(panel_width - panel_padding)

	local perk_texture, perk_rect = tweak_data.skilltree:get_specialization_icon_data()
	local perk_icon = panel:bitmap({
		y = panel_padding,
		texture = perk_texture,
		texture_rect = perk_rect,
		w = perk_icon_size,
		h = perk_icon_size
	})
	perk_icon:set_right(panel_width - panel_padding)

	local skillpoints = managers.skilltree:points()
	local unspent_text, skill_icon, skill_glow
	if skillpoints > 0 then
		unspent_text = panel:text({
			y = math.round(continental_text:bottom() + font_size * 0.5),
			align = "center",
			horizontal = "center",
			layer = 1,
			text = managers.localization:to_upper_text(skillpoints > 1 and "menu_hophud_unspent_points" or "menu_hophud_unspent_point", { AMOUNT = skillpoints }),
			font_size = font_size,
			font = font,
			color = tweak_data.screen_colors.text
		})
		self:_make_fine_text(unspent_text)
		unspent_text:set_center_x(panel_width * 0.5 + 8)

		skill_icon = panel:bitmap({
			w = 16,
			texture = "guis/textures/pd2/shared_skillpoint_symbol",
			h = 16,
			layer = 1
		})
		skill_icon:set_right(unspent_text:left())
		skill_icon:set_center_y(unspent_text:center_y() + 1)

		skill_glow = panel:bitmap({
			texture = "guis/textures/pd2/crimenet_marker_glow",
			blend_mode = "add",
			layer = 0,
			w = unspent_text:w() + 16,
			h = unspent_text:h() * 2,
			color = tweak_data.screen_colors.button_stage_3
		})
		skill_glow:set_center_y(unspent_text:center_y() + 1)
	end

	self._panel = panel

	self._panel:set_size(panel_width, math.max(unspent_text and unspent_text:bottom() + panel_padding or continental_text:bottom() + panel_padding, avatar_panel:bottom() + panel_padding))
	self._panel:set_bottom(self._panel:parent():h() - self.BOTTOM_OFFSET)
	BoxGuiObject:new(self._panel, {sides = { 1, 1, 1, 1 }})

	if skill_glow then

		local function animate_new_skillpoints(o)
			while true do
				over(1, function (p)
					o:set_alpha(math.lerp(0.4, 0.85, math.sin(p * 180)))
				end)
			end
		end

		skill_glow:set_w(unspent_text:w() * 2)
		skill_glow:set_center_x(unspent_text:center_x() - skill_icon:w() * 0.5)
		skill_glow:animate(animate_new_skillpoints)
	end

	self:_rec_round_object(panel)
end
