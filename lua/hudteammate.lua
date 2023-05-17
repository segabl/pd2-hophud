Hooks:PostHook(HUDTeammate, "init", "init_hophud", function (self)
	local name = self._panel:child("name")
	local name_bg = self._panel:child("name_bg")
	local bg_color = Color.white / 3
	local bg_rect = { 84, 0, 44, 32 }

	self._downs_icon = self._panel:bitmap({
		visible = not HopHUD.settings.disable_down_counter,
		name = "down_icon",
		texture = "guis/textures/pd2/arrow_downcounter",
		layer = 1,
		h = tweak_data.hud_players.name_size,
		w = tweak_data.hud_players.name_size * 0.5,
	})

	self._downs = self._panel:text({
		visible = not HopHUD.settings.disable_down_counter,
		name = "downs",
		vertical = "center",
		layer = 1,
		text = "0",
		color = Color.white,
		font_size = tweak_data.hud_players.name_size,
		font = tweak_data.hud_players.name_font,
		h = name_bg:h()
	})

	self._downs_bg = self._panel:bitmap({
		visible = not HopHUD.settings.disable_down_counter,
		name = "downs_bg",
		layer = 0,
		texture = "guis/textures/pd2/hud_tabs",
		texture_rect = bg_rect,
		color = bg_color,
		h = name_bg:h()
	})

	self._player_panel:child("revive_panel"):set_visible(false)

	if HopHUD.settings.restore_callsigns then
		self._panel:child("callsign_bg"):set_visible(true)
		self._panel:child("callsign"):set_visible(true)
	else
		name:set_x(name:x() - name:h())
		name_bg:set_x(name:x())
	end

	if not HopHUD.settings.kill_counter then
		return
	end

	self._kills_icon = self._panel:bitmap({
		name = "skull",
		texture = "guis/textures/pd2/kills_icon",
		layer = 1,
		h = tweak_data.hud_players.name_size,
		w = tweak_data.hud_players.name_size,
	})

	self._kills = self._panel:text({
		name = "kills",
		vertical = "center",
		layer = 1,
		text = "0",
		color = Color.white,
		font_size = tweak_data.hud_players.name_size,
		font = tweak_data.hud_players.name_font,
		h = name_bg:h()
	})

	self._kills_bg = self._panel:bitmap({
		name = "kills_bg",
		visible = true,
		layer = 0,
		texture = "guis/textures/pd2/hud_tabs",
		texture_rect = bg_rect,
		color = bg_color,
		h = name_bg:h()
	})
end)

function HUDTeammate:animate_invulnerability(duration)
	self._radial_health_panel:child("radial_custom"):animate(function (o)
		o:set_color(Color(1, 1, 1, 1))
		o:set_visible(true)
		over(duration, function (p)
			o:set_color(Color(1, 1 - p, 1, 1))
		end)
		o:set_visible(false)
	end)
end

function HUDTeammate:_animate_bullet_storm(weapons_panel, duration)
	if not weapons_panel then
		return
	end

	local ammo_text = weapons_panel:child("ammo_clip")
	local panel = weapons_panel:child("bulletstorm")
	if not panel then
		panel = weapons_panel:panel({
			name = "bulletstorm",
			w = ammo_text:w() * 2,
			h = ammo_text:h() * 2
		})
		panel:set_world_center(ammo_text:world_center_x(), weapons_panel:world_center_y())

		panel:bitmap({
			name = "effect",
			texture = "guis/textures/pd2/crimenet_marker_glow",
			layer = 0,
			alpha = 0,
			w = panel:w(),
			h = panel:h(),
			color = tweak_data.screen_colors.button_stage_3
		})

		local text = panel:text({
			layer = 1,
			text = "8",
			font = tweak_data.hud_players.ammo_font,
			font_size = ammo_text:font_size() * 1.25,
			rotation = 90
		})
		text:set_shape(text:text_rect())
		text:set_center(panel:w() * 0.5, panel:h() * 0.5)
	end

	local effect = panel:child("effect")

	weapons_panel:stop()
	weapons_panel:animate(function ()
		ammo_text:hide()
		panel:show()

		local t = 0
		while t < duration do
			t = t + coroutine.yield()

			local a = math.map_range(math.sin(t * 360), -1, 1, 0, 1)
			effect:set_alpha(a)
		end

		panel:hide()
		ammo_text:show()
	end)
end

function HUDTeammate:animate_bulletstorm(duration)
	local weapons_panel = self._player_panel:child("weapons_panel")
	if not weapons_panel then
		return
	end

	self:_animate_bullet_storm(weapons_panel:child("primary_weapon_panel"), duration)
	self:_animate_bullet_storm(weapons_panel:child("secondary_weapon_panel"), duration)
end

Hooks:PostHook(HUDTeammate, "set_state", "set_state_hophud", function (self, state)
	local is_player = state == "player"

	self._downs_bg:set_visible(is_player and not HopHUD.settings.disable_down_counter)
	self._downs_icon:set_visible(is_player and not HopHUD.settings.disable_down_counter)
	self._downs:set_visible(is_player and not HopHUD.settings.disable_down_counter)

	if not self._main_player and not HopHUD.settings.restore_callsigns then
		local name = self._panel:child("name")
		local name_bg = self._panel:child("name_bg")
		name:set_x(name:x() - name:h())
		name_bg:set_x(name:x())
	end

	self:_update_down_counter()
end)

Hooks:PostHook(HUDTeammate, "set_revives_amount", "set_revives_amount_hophud", function (self, revive_amount)
	self._downs:set_color(revive_amount > 1 and Color.white or Color.red)
	self._downs:set_text(tostring(math.max(revive_amount - 1, 0)))
	self:_update_down_counter()
end)

Hooks:PostHook(HUDTeammate, "set_callsign", "set_callsign_hophud", function (self, id)
	if not HopHUD.settings.health_colors then
		return
	end
	local radial_health = self._radial_health_panel:child("radial_health")
	if type(radial_health) ~= "userdata" then
		return
	end
	radial_health:set_blend_mode("normal")
	radial_health:set_image("guis/textures/pd2/hud_health_" .. ((id - 1) % 4 + 1))
	radial_health:set_texture_rect(128, 0, -128, 128)
end)

function HUDTeammate:_update_down_counter()
	local name_bg = self._panel:child("name_bg")

	self._downs_bg:set_x(name_bg:right() + 2)
	self._downs_bg:set_y(name_bg:y())
	self._downs_icon:set_x(self._downs_bg:x() + 2)
	self._downs_icon:set_center_y(self._downs_bg:center_y())
	self._downs:set_x(self._downs_icon:right() + 2)
	self._downs:set_y(name_bg:y())
	local _, _, downs_w, _ = self._downs:text_rect()
	self._downs_bg:set_w(2 + self._downs_icon:w() + 2 + downs_w + 4)

	self:_update_kill_panel()
end

function HUDTeammate:_update_kill_panel()
	if not self._kills then
		return
	end

	local align_point = self._downs_bg:visible() and self._downs_bg or self._panel:child("name_bg")

	self._kills_bg:set_x(align_point:right() + 2)
	self._kills_bg:set_y(align_point:y())
	self._kills_icon:set_x(self._kills_bg:x())
	self._kills_icon:set_center_y(self._kills_bg:center_y())
	self._kills:set_x(self._kills_icon:right())
	self._kills:set_y(align_point:y())
	local _, _, kills_w, _ = self._kills:text_rect()
	self._kills_bg:set_w(self._kills_icon:w() + kills_w + 4)
end
