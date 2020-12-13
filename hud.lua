if not HopHUD then

  local tex_ids = Idstring("texture")
  HopLib:load_assets({
    { ext = tex_ids, path = Idstring("guis/textures/pd2/hud_health_1"), file = ModPath .. "assets/guis/textures/pd2/hud_health_1.texture" },
    { ext = tex_ids, path = Idstring("guis/textures/pd2/hud_health_2"), file = ModPath .. "assets/guis/textures/pd2/hud_health_2.texture" },
    { ext = tex_ids, path = Idstring("guis/textures/pd2/hud_health_3"), file = ModPath .. "assets/guis/textures/pd2/hud_health_3.texture" },
    { ext = tex_ids, path = Idstring("guis/textures/pd2/hud_health_4"), file = ModPath .. "assets/guis/textures/pd2/hud_health_4.texture" }
  })

  _G.HopHUD = {}
  HopHUD.mod_path = ModPath
  HopHUD.damage_pops = {}
  HopHUD.damage_pop_key = 1
  HopHUD.colors = {
    default = Color.white,
    rank = Color.white,
    level = Color.white:with_alpha(0.8),
    action = Color.white:with_alpha(0.8)
  }

  local DamagePop = class()
  HopHUD.DamagePop = DamagePop

  function DamagePop:init(position, damage, is_head, is_kill, is_special, color)
    self._panel = HopHUD._panel:panel({
      name = "panel",
      visible = false
    })
    local damage_text = string.format(damage < 1 and "%1.1f" or "%u", damage) .. (is_kill and "" or "")
    local text = self._panel:text({
      name = "text",
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

    self._position = position
    self._created_t = HopHUD._t
    self._lifetime = 1
  end

  local screen_pos = Vector3()
  local world_pos = Vector3()
  function DamagePop:update(t, cam, cam_forward)
    local f = (t - self._created_t) / self._lifetime
    if f > 1 then
      if not self.dead then
        self:destroy()
      end
      return
    end
    mvector3.set(world_pos, self._position)
    mvector3.set(screen_pos, HopHUD._ws:world_to_screen(cam, world_pos))
    mvector3.subtract(world_pos, cam:position())
    mvector3.normalize(world_pos)
    local _f = math.min(f * 1.5, 1)
    self._panel:set_center(screen_pos.x, screen_pos.y - 2 * self._panel:h() * (math.pow(_f - 1, 3) + 1))
    self._panel:set_alpha(1.5 * (1 - f))
    self._panel:set_visible(mvector3.dot(cam_forward, world_pos) >= 0)
  end

  function DamagePop:destroy()
    HopHUD._panel:remove(self._panel)
    self.dead = true
  end

  function HopHUD:add_damage_pop(unit, damage_info)
    local attacker_info = HopLib:unit_info_manager():get_user_info(damage_info.attacker_unit)
    if not attacker_info then
      return
    end
    -- only show dmg pop if the attacker is on criminal team
    local attacker_team = alive(attacker_info._unit) and attacker_info._unit:movement() and attacker_info._unit:movement():team()
    if not attacker_team or (attacker_team.id ~= "criminal1" and not attacker_team.friends.criminal1 and attacker_team.id ~= "hacked_turret") then
      return
    end
    local info = HopLib:unit_info_manager():get_info(unit)
    local col_ray = damage_info.col_ray or {}
    local pos = col_ray.position or damage_info.pos or col_ray.hit_position or unit:position() + Vector3(0, 0, 80)
    local unit_damage = unit:character_damage()
    local unit_base = unit:base()
    local is_head = unit_damage.is_head and unit_damage:is_head(col_ray.body)
    local is_kill = unit_damage._dead
    local is_special = info._is_special or info._is_boss
    local color_id = attacker_info._color_id

    local pop = DamagePop:new(pos, damage_info.damage * 10, is_head, is_kill, is_special, color_id and color_id < #tweak_data.chat_colors and tweak_data.chat_colors[color_id])
    if self.damage_pops[self.damage_pop_key] then
      self.damage_pops[self.damage_pop_key]:destroy()
    end
    self.damage_pops[self.damage_pop_key] = pop
    self.damage_pop_key = (self.damage_pop_key < 1000 and self.damage_pop_key or 0) + 1
  end

  function HopHUD:init()
    local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2)
    self._ws = managers.hud._workspace
    self._panel = self._panel or hud and hud.panel or self._ws:panel({ name = "HopHUD" })
  end

  local cam_forward = Vector3()
  function HopHUD:update(t, dt)
    self._t = t
    if self._update_t and t < self._update_t + 0.03 then
      return
    end
    local cam = managers.viewport:get_current_camera()
    if not cam then
      return
    end
    mrotation.y(cam:rotation(), cam_forward)
    for k, pop in pairs(self.damage_pops) do
      if pop.dead then
        self.damage_pops[k] = nil
      else
        pop:update(t, cam, cam_forward)
      end
    end
    self._update_t = t
  end

  function HopHUD:rank_and_level_string(rank, level)
    local rank_string = rank and rank > 0 and (managers.experience:rank_string(rank) .. "Ї") or ""
    local level_string = level ~= nil and tostring(level) or ""
    return rank_string, level_string
  end

  function HopHUD:set_name_panel_text(text, name, level, rank, color_id)
    local rank_string, level_string = self:rank_and_level_string(rank, level)
    local name_string = rank_string .. level_string .. " " .. tostring(name)
    text:set_text(name_string)
    if color_id and tweak_data.chat_colors[color_id] then
      text:set_range_color(0 + utf8.len(rank_string .. level_string), 0 + utf8.len(name_string), tweak_data.chat_colors[color_id])
    else
      text:set_range_color(0 + utf8.len(rank_string .. level_string), 0 + utf8.len(name_string), Color.white)
    end
    text:set_range_color(0, 0 + utf8.len(rank_string), HopHUD.colors.rank)
    text:set_range_color(0 + utf8.len(rank_string), 0 + utf8.len(rank_string .. level_string), HopHUD.colors.level)
  end

  function HopHUD:set_teammate_name_panel(panel, name, color_id)
    local name_panel = panel._panel:child("name")
    local o_name = name
    while true do
      local name_string = name
      panel:set_name(name_string)
      local _, _, name_w, _ = name_panel:text_rect()
      if name_w > panel._panel:w() - name_panel:left() - 48 and utf8.len(o_name) > 0 then
        o_name = o_name:sub(1, utf8.len(o_name) - 1)
        name = o_name .. "..."
      else
        break
      end
    end

    if color_id and tweak_data.chat_colors[color_id] then
      panel:set_callsign(color_id)
      name_panel:set_color(HopHUD.colors.default)
    end

    panel:_update_kill_panel()
  end

  function HopHUD:update_kill_counter(unit)
    local info = HopLib:unit_info_manager():get_user_info(unit)
    if not info then
      return
    end

    if info._type ~= "player" and info._sub_type ~= "team_ai" then
      return
    end

    local panel = info._sub_type == "local_player" and managers.hud:get_teammate_panel_by_peer()
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
    local level = info._level or info._sub_type == "team_ai" and "Bot" or (info._sub_type or info._type):pretty(true)
    return info:nickname(), level, info._rank, info._color_id
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

  Hooks:Add("HopLibOnUnitDamaged", "HopLibOnUnitDamagedHopHud", function (unit, damage_info)
    if type(damage_info.damage) == "number" and damage_info.damage > 0 then
      HopHUD:add_damage_pop(unit, damage_info)
      if unit:character_damage():dead() then
        HopHUD:update_kill_counter(damage_info.attacker_unit)
      end
    end
  end)

  Hooks:Add("HopLibOnMinionAdded", "HopLibOnMinionAddedHopHud", function (unit, player_unit)
    local color = tweak_data.peer_vector_colors[player_unit and player_unit:network():peer():id() or managers.network:session():local_peer():id()] or tweak_data.contour.character.friendly_color
    unit:contour():change_color("friendly", color)
  end)

  Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInitStreamlinedHeisting", function (loc)
    HopLib:load_localization(HopHUD.mod_path .. "loc/", loc)
  end)

end

if tweak_data then
  tweak_data.hud.name_label_font_size = tweak_data.hud_players.name_size
end

if RequiredScript then

  local fname = HopHUD.mod_path .. RequiredScript:gsub(".+/(.+)", "lua/%1.lua")
  if io.file_is_readable(fname) then
    dofile(fname)
  end

end

if Keepers and not HopHUD._modified_Keepers then

  local reset_label_original = Keepers.ResetLabel or Keepers.reset_label
  function Keepers:reset_label(unit, is_converted, icon, ...)
    reset_label_original(self, unit, is_converted, BotWeapons and BotWeapons.settings.player_carry and icon == "pd2_loot" and "wp_arrow" or icon, ...)
  end
  Keepers.ResetLabel = Keepers.reset_label

  local set_joker_label_original = Keepers.SetJokerLabel or Keepers.set_joker_label
  function Keepers:set_joker_label(unit, ...)
    set_joker_label_original(self, unit, ...)

    local name_label = managers.hud:_get_name_label(unit:unit_data().name_label_id)
    if not name_label then
      return
    end

    local radial_health = name_label.panel:child("bag")
    radial_health:set_image("guis/textures/pd2/hud_health_" .. unit:base().kpr_minion_owner_peer_id)
    radial_health:set_blend_mode("normal")

    unit:contour():change_color("friendly", tweak_data.peer_vector_colors[unit:base().kpr_minion_owner_peer_id] or tweak_data.contour.character.friendly_color)
  end
  Keepers.SetJokerLabel = Keepers.set_joker_label

  HopHUD._modified_Keepers = true

end
