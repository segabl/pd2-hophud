if not MyHUD then

  _G.MyHUD = {}
  MyHUD.mod_path = ModPath
  MyHUD.hooks = {
    ["lib/managers/criminalsmanager"] = "criminalsmanager.lua",
    ["lib/managers/group_ai_states/groupaistatebase"] = "groupaistatebase.lua",
    ["lib/managers/hudmanager"] = "hudmanager.lua",
    ["lib/managers/hudmanagerpd2"] = "hudmanagerpd2.lua",
    ["lib/managers/hud/hudheisttimer"] = "hudheisttimer.lua",
    ["lib/managers/hud/hudlootscreen"] = "hudlootscreen.lua",
    ["lib/managers/hud/hudmissionbriefing"] = "hudmissionbriefing.lua",
    ["lib/managers/menu/contractboxgui"] = "contractboxgui.lua",
    ["lib/network/handlers/unitnetworkhandler"] = "unitnetworkhandler.lua",
    ["lib/units/contourext"] = "contourext.lua",
    ["lib/units/enemies/cop/copdamage"] = "copdamage.lua"
  }
  
  MyHUD.damage_pops = {}
  MyHUD.damage_pop_key = 1
  
  local DamagePop = class()
  MyHUD.DamagePop = DamagePop
  
  function DamagePop:init(position, damage, is_head, is_kill, is_special, color)
    self._panel = MyHUD._panel:panel({
      name = "panel",
      visible = false
    })
    local damage_text = string.format(damage < 1 and "%1.1f" or "%u", damage) .. (is_kill and "" or "")
    local text = self._panel:text({
      name = "text",
      text = damage_text,
      font = tweak_data.menu.pd2_medium_font,
      font_size = 24,
      color = color or Color.white,
      layer = 100
    })
    if is_kill and is_special then
      text:set_range_color(utf8.len(damage_text) - 1, utf8.len(damage_text), Color.yellow)
    end
    local _, _, w, h = text:text_rect()
    self._panel:set_size(w, h)
    
    self._position = position
    self._created_t = MyHUD._t
    self._lifetime = 1
  end

  function DamagePop:update(t, cam, cam_forward)
    if self.dead then
      return
    end
    local f = (t - self._created_t) / self._lifetime
    if f > 1 then
      self.dead = true
      return
    end
    local screen_pos = Vector3()
    local world_pos = Vector3()
    mvector3.set(world_pos, self._position)
    mvector3.set(screen_pos, MyHUD._ws:world_to_screen(cam, world_pos))
    mvector3.subtract(world_pos, cam:position())
    mvector3.normalize(world_pos)
    local offset = math.max(0, 0.75 - f)
    self._panel:set_center(screen_pos.x, screen_pos.y + 4 * offset * offset * self._panel:h())
    self._panel:set_alpha(math.min(1, 1.5 * (1 - f)))
    self._panel:set_visible(mvector3.dot(cam_forward, world_pos) >= 0)
  end

  function DamagePop:destroy()
    MyHUD._panel:remove(self._panel)
  end

  function MyHUD:add_damage_pop(unit, info)
    if not alive(unit) or not info or not info.damage or info.damage == 0 then
      return
    end
    local col_ray = info.col_ray or {}
    local pos = Vector3()
    mvector3.set(pos, col_ray.position or info.pos or col_ray.hit_position or unit:position())
    mvector3.set_z(pos, mvector3.z(pos) + 30)
    local unit_damage = unit:character_damage()
    local unit_base = unit:base()
    local is_head = unit_damage.is_head and unit_damage:is_head(col_ray.body)
    local is_kill = unit_damage._dead or unit_damage._health <= 0
    local is_special = unit_base._tweak_table and tweak_data.character[unit_base._tweak_table] and tweak_data.character[unit_base._tweak_table].priority_shout
    local attacker = info.attacker_unit
    local attacker_base = alive(attacker) and attacker:base()
    if attacker_base then
      local thrower = attacker_base._thrower_unit
      local owner = attacker_base._owner or attacker_base.get_owner and attacker_base:get_owner()
      attacker = thrower or owner or attacker
    end
    local color_id = attacker and managers.criminals:character_color_id_by_unit(attacker)
    local pop = DamagePop:new(pos, info.damage * 10, is_head, is_kill, is_special, color_id and color_id < #tweak_data.chat_colors and tweak_data.chat_colors[color_id])
    self.damage_pops[self.damage_pop_key] = pop
    self.damage_pop_key = (self.damage_pop_key < 10000 and self.damage_pop_key or 0) + 1
  end
  
  function MyHUD:check_create_panel()
    self._ws = managers.hud._workspace
    self._panel = self._panel or self._ws:panel({ name = "MyHUD" })
  end

  function MyHUD:update(t, dt)
    self._t = t
    if self._update_t and t < self._update_t + 0.03 then
      return
    end
    local cam = managers.viewport:get_current_camera()
    if not cam then
      return
    end
    local cam_forward = Vector3()
    mrotation.y(cam:rotation(), cam_forward)
    for _, pop in pairs(self.damage_pops) do
      if pop.dead then
        pop:destroy()
        pop = nil
      else
        pop:update(t, cam, cam_forward)
      end
    end
    self._update_t = t
  end

  function MyHUD:rank_and_level_string(rank, level)
    local rank_string = rank and rank > 0 and (managers.experience:rank_string(rank) .. "Ї") or ""
    local level_string = level ~= nil and tostring(level) or ""
    return rank_string, level_string
  end

  function MyHUD:set_name_panel_text(text, name, level, rank, color_id)
    local rank_string, level_string = self:rank_and_level_string(rank, level)
    local name_string = rank_string .. level_string .. " " .. name
    text:set_text(name_string)
    if color_id and tweak_data.chat_colors[color_id] then
      text:set_color(tweak_data.chat_colors[color_id])
    end
    text:set_range_color(0, utf8.len(rank_string), Color.white)
    text:set_range_color(utf8.len(rank_string), utf8.len(rank_string .. level_string), Color.white:with_alpha(0.8))
  end

  function MyHUD:set_teammate_name_panel(panel, name, level, rank, color_id)
    local rank_string, level_string = self:rank_and_level_string(rank, level)
    local name_string = rank_string .. level_string .. " " .. name
    
    local name = panel._panel:child("name")
    
    panel:set_name(name_string)   
    if color_id and tweak_data.chat_colors[color_id] then
      panel:set_callsign(color_id)
      name:set_color(tweak_data.chat_colors[color_id])
    end
    name:set_range_color(1, utf8.len(rank_string) + 1, Color.white)
    name:set_range_color(utf8.len(rank_string) + 1, utf8.len(rank_string .. level_string) + 1, Color.white:with_alpha(0.8))
  end

  function MyHUD:information_by_unit(unit)
    if not unit or not alive(unit) then
      return
    end
    local name = unit:base()._tweak_table
    local level = managers.groupai:state():is_unit_team_AI(unit) and "Bot" or managers.groupai:state():is_enemy_converted_to_criminal(unit) and "Joker"
    local rank
    local color_id = managers.criminals:character_color_id_by_unit(unit)
    if unit:base().is_husk_player then
      name = unit:network():peer():name()
      level = unit:network():peer():level()
      rank = unit:network():peer():rank()
    end
    return name, level, rank, color_id
  end

  function MyHUD:information_by_peer(peer)
    local local_peer = managers.network:session():local_peer()
    local name = peer == local_peer and local_peer:name() or peer and peer:name() or ""
    local level = peer == local_peer and managers.experience:current_level() or peer and peer:level()
    local rank = peer == local_peer and managers.experience:current_rank() or peer and peer:rank()
    local color_id = peer == local_peer and local_peer:id() or peer and peer:id() or 1
    return name, level, rank, color_id
  end

end

if RequiredScript then

  local requiredScript = RequiredScript:lower()
  if MyHUD.hooks[requiredScript] then
    dofile(MyHUD.mod_path .. "lua/" .. MyHUD.hooks[requiredScript])
  end

end
