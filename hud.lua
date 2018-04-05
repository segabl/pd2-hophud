if not HopLib then
  return
end

if not HopHUD then

  tweak_data.hud.name_label_font_size = tweak_data.hud_players.name_size

  _G.HopHUD = {}
  HopHUD.mod_path = ModPath
  HopHUD.hooks = {
    ["lib/managers/criminalsmanager"] = "lua/criminalsmanager.lua",
    ["lib/managers/group_ai_states/groupaistatebase"] = "lua/groupaistatebase.lua",
    ["lib/managers/hudmanager"] = "lua/hudmanager.lua",
    ["lib/managers/hudmanagerpd2"] = "lua/hudmanagerpd2.lua",
    ["lib/managers/hud/hudheisttimer"] = "lua/hudheisttimer.lua",
    ["lib/managers/hud/hudlootscreen"] = "lua/hudlootscreen.lua",
    ["lib/managers/hud/hudmissionbriefing"] = "lua/hudmissionbriefing.lua",
    ["lib/managers/menu/contractboxgui"] = "lua/contractboxgui.lua",
    ["lib/managers/menu/lobbycharacterdata"] = "lua/lobbycharacterdata.lua",
    ["lib/managers/menu/menucomponentmanager"] = "lua/menucomponentmanager.lua",
    ["lib/managers/menu/playerprofileguiobject"] = "lua/playerprofileguiobject.lua",
    ["lib/network/handlers/unitnetworkhandler"] = "lua/unitnetworkhandler.lua",
    ["lib/units/contourext"] = "lua/contourext.lua"
  }
  
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
    self._unit_info_text = self._panel:text({
      text = "Nobody",
      font = tweak_data.menu.pd2_medium_font,
      font_size = tweak_data.hud.name_label_font_size,
      color = Color.white,
      align = "center",
      y = 100,
      visible = false
    })
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
    for _, pop in pairs(self.damage_pops) do
      if pop.dead then
        pop = nil
      else
        pop:update(t, cam, cam_forward)
      end
    end
    --[[
    local from = cam:position()
    mvector3.multiply(cam_forward, 10000)
    mvector3.add(cam_forward, from)
    local col = World:raycast("ray", from, cam_forward, "slot_mask", managers.slot:get_mask("raycastable_characters"))
    local info = col and HopLib:unit_info_manager():get_info(col.unit)
    if info then
      self._unit_info_text:set_visible(true)
      self._unit_info_text:set_text(info:nickname())
    else
      self._unit_info_text:set_visible(false)
    end
    ]]
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

  function HopHUD:set_teammate_name_panel(panel, name, level, rank, color_id)
    name = utf8.len(name) > 16 and name:sub(1, 16) .. "..." or name
  
    local rank_string, level_string = self:rank_and_level_string(rank, level)
    local name_string = rank_string .. level_string .. " " .. name
    
    local name = panel._panel:child("name")
    
    panel:set_name(name_string)
    if color_id and tweak_data.chat_colors[color_id] then
      panel:set_callsign(color_id)
      name:set_color(tweak_data.chat_colors[color_id])
    end
    name:set_range_color(1, utf8.len(rank_string) + 1, HopHUD.colors.rank)
    name:set_range_color(utf8.len(rank_string) + 1, utf8.len(rank_string .. level_string) + 1, HopHUD.colors.level)
  end
  
  function HopHUD:create_kill_counter(panel)
    local teammate_panel = panel._panel
    local name = teammate_panel:child("name")
    local _, _, name_w, _ = name:text_rect()

    if not teammate_panel:child("skull") then
      local skull = teammate_panel:text({
        name = "skull",
        layer = 1,
        text = "",
        color = Color.yellow,
        font_size = tweak_data.hud_players.name_size,
        font = tweak_data.menu.pd2_medium_font
      })
      managers.hud:make_fine_text(skull)
      local _, _, skull_w, skull_h = skull:text_rect()
      skull:set_size(skull_w, skull_h)
      skull:set_x(name:left() + name_w + 10)
      skull:set_center_y(name:center_y())
      
      local kills = teammate_panel:text({
        name = "kills",
        vertical = "bottom",
        y = 0,
        layer = 1,
        text = "0",
        color = Color.white,
        font_size = tweak_data.hud_players.name_size,
        font = tweak_data.hud_players.name_font
      })
      local _, _, kills_w, kills_h = kills:text_rect()
      kills:set_size(kills_w, kills_h)
      kills:set_x(skull:left() + skull_w)
      kills:set_bottom(name:bottom())
      
      teammate_panel:bitmap({
        name = "kills_bg",
        visible = true,
        layer = 0,
        texture = "guis/textures/pd2/hud_tabs",
        texture_rect = { 84, 0, 44, 32 },
        color = Color.white / 3,
        x = skull:x() - 2,
        y = name:y() - 1,
        w = skull_w + kills_w + 6,
        h = name:h()
      })
    else
      local skull = teammate_panel:child("skull")
      local _, _, skull_w, _ = skull:text_rect()
      skull:set_x(name:left() + name_w + 10)
      skull:set_center_y(name:center_y())
      local kills = teammate_panel:child("kills")
      local _, _, kills_w, kills_h = kills:text_rect()
      kills:set_size(kills_w, kills_h)
      kills:set_x(skull:left() + skull_w)
      kills:set_bottom(name:bottom())
      local kills_bg = teammate_panel:child("kills_bg")
      kills_bg:set_position(skull:x() - 2, name:y() - 1)
    end
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
    local _, _, old_kills_w, _ = kills:text_rect()
    local kills_bg = teammate_panel:child("kills_bg")
    
    kills:set_text("" .. info._kills)
    local _, _, kills_w, kills_h = kills:text_rect()
    kills:set_size(kills_w, kills_h)
    
    kills_bg:set_w(kills_bg:w() - old_kills_w + kills_w)
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

end

if HopHUD.hooks[RequiredScript] then
  dofile(HopHUD.mod_path .. HopHUD.hooks[RequiredScript])
end

if Keepers and not HopHUD._modified_Keepers then

  local ResetLabel_original = Keepers.ResetLabel
  function Keepers:ResetLabel(unit, is_converted, icon, ...)
    ResetLabel_original(self, unit, is_converted, BotWeapons and BotWeapons._data.player_carry and icon == "pd2_loot" and "wp_arrow" or icon, ...)
  end

  HopHUD._modified_Keepers = true

end
