if not HopHUD then

	local tex_ids = Idstring("texture")
	HopLib:load_assets({
		{ ext = tex_ids, path = Idstring("guis/textures/pd2/hud_health_1"), file = ModPath .. "assets/guis/textures/pd2/hud_health_1.dds" },
		{ ext = tex_ids, path = Idstring("guis/textures/pd2/hud_health_2"), file = ModPath .. "assets/guis/textures/pd2/hud_health_2.dds" },
		{ ext = tex_ids, path = Idstring("guis/textures/pd2/hud_health_3"), file = ModPath .. "assets/guis/textures/pd2/hud_health_3.dds" },
		{ ext = tex_ids, path = Idstring("guis/textures/pd2/hud_health_4"), file = ModPath .. "assets/guis/textures/pd2/hud_health_4.dds" },
		{ ext = tex_ids, path = Idstring("guis/textures/pd2/kills_icon"), file = ModPath .. "assets/guis/textures/pd2/kills_icon.dds" },
		{ ext = tex_ids, path = Idstring("guis/textures/pd2/wp_checkmark"), file = ModPath .. "assets/guis/textures/pd2/wp_checkmark.dds" }
	})

	_G.HopHUD = {}
	HopHUD.mod_path = ModPath
	HopHUD.colors = {
		default = Color.white,
		rank = Color.white,
		level = Color.white:with_alpha(0.8),
		action = Color.white:with_alpha(0.8),
		skull = Color.yellow,
		in_payday = Color(0.75, 1, 0.5),
		online = Color(0.5, 0.75, 1),
		in_game = Color(0.75, 0.5, 0.75, 1),
		snooze = Color(0.35, 0.5, 0.75, 1),
		away = Color(0.35, 0.5, 0.75, 1),
		offline = Color(0.35, 1, 1, 1)
	}
	HopHUD.settings = {
		bot_colors = true,
		joker_colors = true,
		chat_sounds = true,
		civilian_icons = true,
		custom_timer = true,
		damage_pops = {
			damage_pops_style = 1,
			local_player = true,
			remote_player = true,
			team_ai = true,
			joker = true,
			sentry = true,
			npc = true,
			combine_pops = false
		},
		display_invulnerability = true,
		display_bulletstorm = true,
		health_colors = true,
		kill_counter = true,
		main_menu_panel = true,
		hide_content_updates = false,
		hide_news_feed = false,
		hq_fonts = false,
		restore_callsigns = true,
		disable_down_counter = false,
		name_labels = {
			alternative_rank_style = true,
			disable_rank = false,
			uppercase_names = false,
			smaller_name_labels = true,
			label_unit_type = true
		}
	}
	HopHUD.params = {
		main_menu_panel = { priority = 12 },
		hide_content_updates = { priority = 11 },
		hide_news_feed = { priority = 10, divider = 12 },
		chat_sounds = { priority = 9, divider = 12 },
		bot_colors = { priority = 8 },
		joker_colors = { priority = 7, divider = 12 },
		kill_counter = { priority = 6 },
		health_colors = { priority = 5 },
		restore_callsigns = { priority = 4 },
		disable_down_counter = { priority = 3 },
		display_invulnerability = { priority = 2 },
		display_bulletstorm = { priority = 1, divider = 12 },
		name_labels = { divider = -12, priority = -999 },
		damage_pops = { priority = -1000 },
		damage_pops_style = { priority = 11, divider = 8, items = { "menu_hophud_damage_pops_classic", "menu_hophud_damage_pops_burst" } },
		local_player = { priority = 10 },
		remote_player = { priority = 9 },
		team_ai = { priority = 8 },
		joker = { priority = 7 },
		sentry = { priority = 6 },
		npc = { priority = 5 },
		combine_pops = { divider = -12, priority = -1000 }
	}
	HopHUD.menu_builder = MenuBuilder:new("hophud", HopHUD.settings, HopHUD.params)

	local DamagePop = class()
	HopHUD.DamagePop = DamagePop

	function DamagePop:init(position, damage, is_kill, is_special, color)
		self._panel = HopHUD._panel:panel({
			visible = false
		})
		local damage_text = string.format(damage < 1 and "%1.1f" or "%u", damage) .. (is_kill and "" or "")
		local text = self._panel:text({
			text = damage_text,
			font = tweak_data.menu.pd2_medium_font,
			font_size = tweak_data.hud.name_label_font_size,
			color = color or Color.white,
			layer = 100
		})
		if is_kill and is_special then
			text:set_range_color(utf8.len(damage_text) - 1, utf8.len(damage_text), Color.yellow)
		end
		local _, _, w, h = text:text_rect()
		self._panel:set_size(w, h)

		self._damage = damage
		self._position = position
		self._created_t = TimerManager:game():time()

		self._offset = Vector3()
		if HopHUD.settings.damage_pops.damage_pops_style == 2 then
			self._direction = Vector3(math.rand(-1, 1), -2)
			mvector3.set_length(self._direction, math.rand(200, 300))
		else
			self._direction = Vector3(0, -3 * self._panel:h())
		end

		self._panel:animate(callback(self, self, "animate"))
	end

	function DamagePop:animate()
		local t = 1
		while t > 0 do
			local p = 1 - t
			local dt = coroutine.yield()
			t = t - dt

			local cam = managers.viewport:get_current_camera()
			if not cam then
				self:destroy()
				return
			end

			local screen_pos = HopHUD._ws:world_to_screen(cam, self._position)

			if HopHUD.settings.damage_pops.damage_pops_style == 2 then
				mvector3.add_scaled(self._offset, self._direction, dt / math.max(1, screen_pos.z / 100))
				mvector3.add_scaled(self._direction, math.Y, dt * 800)
			else
				mvector3.set(self._offset, self._direction)
				mvector3.multiply(self._offset, math.pow(math.min(p * 1.5, 1) - 1, 3) + 1)
			end

			self._panel:set_center(screen_pos.x + self._offset.x, screen_pos.y + self._offset.y)
			self._panel:set_alpha(1.5 * (1 - p))
			self._panel:set_visible(screen_pos.z >= 0)
		end

		self:destroy()
	end

	function DamagePop:destroy()
		if alive(self._panel) then
			self._panel:parent():remove(self._panel)
		end
	end

	function HopHUD:add_damage_pop(unit, damage_info)
		if not alive(damage_info.attacker_unit) or not damage_info.attacker_unit:base() then
			return
		end
		local attacker_unit = damage_info.attacker_unit:base().thrower_unit and damage_info.attacker_unit:base():thrower_unit() or damage_info.attacker_unit
		local attacker_info = HopLib:unit_info_manager():get_info(attacker_unit)
		if not attacker_info then
			return
		end
		local owner = attacker_info:owner()
		if not self.settings.damage_pops[attacker_info:type()] or owner and not self.settings.damage_pops[owner:type()] then
			return
		end
		-- only show dmg pop if the attacker is on criminal team
		local attacker_team = alive(attacker_info:unit()) and attacker_info:unit():movement() and attacker_info:unit():movement():team()
		if not attacker_team or (attacker_team.id ~= "criminal1" and not attacker_team.friends.criminal1 and attacker_team.id ~= "hacked_turret") then
			return
		end
		local info = HopLib:unit_info_manager():get_info(unit)
		local unit_dmg = unit:character_damage()
		local col_ray = damage_info.col_ray or {}
		local pos = not damage_info.fire_dot_data and (col_ray.position or col_ray.hit_position or damage_info.pos) or mvector3.copy(unit:movement():m_stand_pos())
		local color = attacker_info._color_id and attacker_info._color_id < #tweak_data.chat_colors and tweak_data.chat_colors[attacker_info._color_id]

		local add_dmg = 0
		if self.settings.damage_pops.combine_pops then
			local last_dmg_pop = unit_dmg._last_dmg_pop and unit_dmg._last_dmg_pop[attacker_info:key()]
			if last_dmg_pop and last_dmg_pop._created_t + 0.05 > TimerManager:game():time() then
				add_dmg = last_dmg_pop._damage
				last_dmg_pop:destroy()
			end
		end

		local pop = DamagePop:new(pos, damage_info.damage * 10 + add_dmg, unit_dmg._dead, info:is_special() or info:is_boss(), color)

		unit_dmg._last_dmg_pop = unit_dmg._last_dmg_pop or {}
		unit_dmg._last_dmg_pop[attacker_info:key()] = pop
	end

	function HopHUD:init()
		self._ws = managers.hud._workspace
		self._panel = self._panel or managers.hud:panel(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2) or self._ws:panel({ name = "HopHUD" })
	end

	function HopHUD:get_name_string_and_colors(name, level, rank, disable_rank)
		local rank_level_string, name_string, color_ranges
		if self.settings.name_labels.alternative_rank_style and not disable_rank then
			local rank_string = type(rank) == "number" and rank > 0 and (managers.experience:rank_string(rank) .. "Ї") or ""
			local level_string = level and tostring(level) or ""
			rank_level_string = rank_string .. level_string
			name_string = rank_level_string .. " " .. tostring(name)
			color_ranges = {
				{
					start = 0,
					stop = utf8.len(rank_string),
					color = HopHUD.colors.rank
				},
				{
					start = utf8.len(rank_string),
					stop = utf8.len(rank_level_string),
					color = HopHUD.colors.level
				},
			}
		elseif disable_rank then
			name_string = name
		else
			rank_level_string, color_ranges = managers.experience:gui_string(level or 0, type(rank) ~= "number" and 0 or rank, utf8.len(tostring(name)) + 2)
			name_string = name .. " (" .. rank_level_string .. ")"
		end

		if self.settings.name_labels.uppercase_names then
			name_string = name_string:upper()
		end

		return name_string, color_ranges or {}
	end

	function HopHUD:set_name_panel_text(text, name, level, rank, color_id, disable_rank)
		if not name then -- Sanity check for vhud+
			return
		end
		local name_string, colors = self:get_name_string_and_colors(name, level, rank, disable_rank)
		text:set_text(name_string)
		text:set_color(tweak_data.chat_colors[color_id] or self.colors.default)
		for _, c in pairs(colors) do
			text:set_range_color(c.start, c.stop, c.color)
		end
	end

	function HopHUD:set_teammate_name_panel(panel, name, color_id)
		if HopHUD.settings.name_labels.uppercase_names then
			name = name:upper()
		end
		local teammate_panel = panel._panel
		local name_panel = teammate_panel:child("name")
		local right_panel = panel._kills_icon or panel._downs_icon or name_panel
		local trimmed_name = name
		while utf8.len(trimmed_name) > 0 do
			panel:set_name(name)
			panel:_update_down_counter()
			if right_panel:right() + tweak_data.hud_players.name_size > teammate_panel:w() then
				trimmed_name = utf8.sub(trimmed_name, 1, -2)
				name = trimmed_name .. "..."
			else
				break
			end
		end

		if color_id and tweak_data.chat_colors[color_id] then
			panel:set_callsign(color_id)
			name_panel:set_color(HopHUD.settings.restore_callsigns and HopHUD.colors.default or tweak_data.chat_colors[color_id])
		end

		panel:_update_kill_panel()
	end

	function HopHUD:update_kill_counter(unit)
		local info = HopLib:unit_info_manager():get_info(unit)
		if info and info._update_owner_stats then
			info = info:owner() or info
		end

		if not info then
			return
		end

		if not info:type():find("player") and info:type() ~= "team_ai" then
			return
		end

		local panel = info:type() == "local_player" and managers.hud:get_teammate_panel_by_peer()
		if not panel then
			local criminal_data = managers.criminals:character_data_by_unit(info._unit)
			local panel_id = criminal_data and criminal_data.panel_id
			panel = managers.hud._teammate_panels[panel_id]
		end

		if not panel then
			return
		end

		local teammate_panel = panel._panel
		local kills = teammate_panel:child("kills")
		if not kills then
			return
		end

		kills:set_text(tostring(info._kills))

		panel:_update_kill_panel()
	end

	function HopHUD:information_by_unit(unit)
		local info = HopLib:unit_info_manager():get_info(unit)
		if not info then
			return
		end
		local level = info:level() or self.settings.name_labels.label_unit_type and managers.localization:text("hud_hophud_unit_type_" .. info:type())
		return info:nickname(), level, info:rank(), info:color_id()
	end

	function HopHUD:information_by_peer(peer)
		local name, level, rank, color_id
		if not managers.network:session() or managers.network:session():local_peer() == peer then
			name = managers.network.account:username() or ""
			level = managers.experience:current_level()
			rank = managers.experience:current_rank()
		else
			name = peer and peer:name() or ""
			level = peer and peer:level()
			rank = peer and peer:rank()
		end
		color_id = peer and peer:id() or 1
		return name, level, rank, color_id
	end

	Hooks:Add("HopLibOnUnitDamaged", "HopLibOnUnitDamagedHopHud", function(unit, damage_info)
		if type(damage_info.damage) == "number" and damage_info.damage > 0 then
			HopHUD:add_damage_pop(unit, damage_info)
			if unit:character_damage():dead() then
				HopHUD:update_kill_counter(damage_info.attacker_unit)
			end
		end
	end)

	Hooks:Add("HopLibOnMinionAdded", "HopLibOnMinionAddedHopHud", function(unit, player_unit)
		if not HopHUD.settings.joker_colors then
			return
		end

		local info = HopLib:unit_info_manager():get_info(player_unit)
		local color = tweak_data.peer_vector_colors[info and info:color_id()] or tweak_data.contour.character.friendly_color
		unit:contour():change_color("friendly", color)
	end)

	Hooks:Add("MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenusHopHud", function(menu_manager, nodes)
		local loc = managers.localization
		HopLib:load_localization(HopHUD.mod_path .. "loc/", loc)
		HopHUD.menu_builder:create_menu(nodes)
	end)

	Hooks:Add("ChatManagerOnReceiveMessage", "ChatManagerOnReceiveMessageHopHud", function(channel_id)
		if channel_id == 1 and HopHUD.settings.chat_sounds then
			managers.menu_component:post_event("menu_enter")
		end
	end)

end

if tweak_data then
	if HopHUD.settings.name_labels.smaller_name_labels then
		tweak_data.hud.name_label_font_size = tweak_data.hud.small_name_label_font_size
	end

	if HopHUD.settings.hq_fonts then
		tweak_data.hud.small_font = tweak_data.hud.medium_font
		tweak_data.menu.small_font = tweak_data.menu.medium_font
		tweak_data.menu.small_font_no_shadow = tweak_data.menu.medium_font_no_outline
		tweak_data.menu.pd2_small_font = tweak_data.menu.pd2_medium_font
		tweak_data.menu.pd2_medium_font = tweak_data.menu.pd2_large_font

		tweak_data.hud_players.name_font = tweak_data.menu.pd2_small_font
		tweak_data.hud_present.title_font = tweak_data.menu.pd2_medium_font
		tweak_data.hud_present.text_font = tweak_data.menu.pd2_medium_font
		tweak_data.hud_mask_off.text_font = tweak_data.menu.pd2_medium_font
		tweak_data.hud_stats.objectives_font = tweak_data.menu.pd2_medium_font
		tweak_data.hud_stats.objective_desc_font = tweak_data.menu.pd2_medium_font
		tweak_data.hud_corner.assault_font = tweak_data.menu.pd2_medium_font
		tweak_data.hud_custody.custody_font = tweak_data.menu.pd2_medium_font
	end
end

HopLib:run_required(HopHUD.mod_path .. "lua/")

if Keepers and not Keepers._modified_by_hophud then

	local reset_label_original = Keepers.reset_label
	function Keepers:reset_label(unit, is_converted, icon, ...)
		reset_label_original(self, unit, is_converted, BotWeapons and BotWeapons.settings.player_carry and icon == "pd2_loot" and "wp_arrow" or icon, ...)
	end

	local set_joker_label_original = Keepers.set_joker_label
	function Keepers:set_joker_label(unit, ...)
		set_joker_label_original(self, unit, ...)

		if not HopHUD.settings.joker_colors then
			return
		end

		local owner_id = unit:base().kpr_minion_owner_peer_id
		if not owner_id then
			local info = HopLib:unit_info_manager():get_info(unit)
			owner_id = info and info:owner() and info:owner():peer() and info:owner():peer():id() or 1
		end

		local name_label = managers.hud:_get_name_label(unit:unit_data().name_label_id)
		if name_label then
			local radial_health = name_label.panel:child("bag")
			radial_health:set_image("guis/textures/pd2/hud_health_" .. owner_id)
			radial_health:set_blend_mode("normal")
		end

		unit:contour():change_color("friendly", tweak_data.peer_vector_colors[owner_id] or tweak_data.contour.character.friendly_color)
	end

	Keepers._modified_by_hophud = true

end
