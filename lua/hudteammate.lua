Hooks:PostHook(HUDTeammate, "init", "init_hophud", function (self)
	if not HopHUD.settings.kill_counter then
		return
	end

	local teammate_panel = self._panel
	local name = teammate_panel:child("name")
	local _, _, name_w, _ = name:text_rect()

	self._skull = teammate_panel:text({
		name = "skull",
		layer = 1,
		text = "",
		color = Color.yellow,
		font_size = tweak_data.hud_players.name_size,
		font = tweak_data.menu.pd2_medium_font
	})
	managers.hud:make_fine_text(self._skull)
	local _, _, skull_w, skull_h = self._skull:text_rect()
	self._skull:set_size(skull_w, skull_h)
	self._skull:set_x(name:left() + name_w + 10)
	self._skull:set_center_y(name:center_y())

	self._kills = teammate_panel:text({
		name = "kills",
		vertical = "bottom",
		y = 0,
		layer = 1,
		text = "0",
		color = Color.white,
		font_size = tweak_data.hud_players.name_size,
		font = tweak_data.hud_players.name_font
	})
	local _, _, kills_w, kills_h = self._kills:text_rect()
	self._kills:set_h(kills_h)
	self._kills:set_x(self._skull:left() + skull_w)
	self._kills:set_bottom(name:bottom())

	self._kills_bg = teammate_panel:bitmap({
		name = "kills_bg",
		visible = true,
		layer = 0,
		texture = "guis/textures/pd2/hud_tabs",
		texture_rect = { 84, 0, 44, 32 },
		color = Color.white / 3,
		x = self._skull:x() - 2,
		y = name:y() - 1,
		w = skull_w + kills_w + 6,
		h = name:h()
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

Hooks:PostHook(HUDTeammate, "set_callsign", "set_callsign_hophud", function (self, id)
	if not HopHUD.settings.health_colors then
		return
	end
	local radial_health = self._radial_health_panel:child("radial_health")
	radial_health:set_image("guis/textures/pd2/hud_health_" .. id)
	radial_health:set_texture_rect(128, 0, -128, 128)
end)

function HUDTeammate:_update_kill_panel()
	if not self._kills then
		return
	end
	local teammate_panel = self._panel
	local name = teammate_panel:child("name")
	local _, _, name_w, _ = name:text_rect()
	local _, _, skull_w, _ = self._skull:text_rect()
	self._skull:set_x(name:left() + name_w + 10)
	self._skull:set_center_y(name:center_y())
	local _, _, kills_w, _ = self._kills:text_rect()
	self._kills:set_x(self._skull:left() + skull_w + 2)
	self._kills:set_bottom(name:bottom())
	self._kills_bg:set_position(self._skull:x() - 2, name:y() - 1)
	self._kills_bg:set_w(skull_w + kills_w + 6)
end
