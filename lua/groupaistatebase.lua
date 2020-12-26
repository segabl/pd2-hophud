if not HopHUD.settings.civilian_icons then
	return
end

Hooks:PreHook(GroupAIStateBase, "_upd_criminal_suspicion_progress", "_upd_criminal_suspicion_progress_hophud", function (self)
	if self._ai_enabled then
		for obs_key, obs_susp_data in pairs(self._suspicion_hud_data or {}) do
			local unit = obs_susp_data.u_observer
			if managers.enemy:is_civilian(unit) then
				local waypoint = managers.hud._hud.waypoints["susp1" .. tostring(obs_key)]
				if waypoint and obs_susp_data.status ~= "called" then
					if unit:anim_data().drop then
						if not obs_susp_data._subdued_civ then
							obs_susp_data._alerted_civ = nil
							obs_susp_data._subdued_civ = true
							waypoint.bitmap:set_image("guis/textures/pd2/wp_checkmark")
							managers.hud:change_waypoint_arrow_color(obs_susp_data.icon_id, tweak_data.hud.suspicion_color)
							waypoint.bitmap:set_color(tweak_data.hud.suspicion_color)
						end
					elseif obs_susp_data.alerted then
						if not obs_susp_data._alerted_civ then
							obs_susp_data._subdued_civ = nil
							obs_susp_data._alerted_civ = true
							managers.hud:change_waypoint_icon(obs_susp_data.icon_id, "wp_detected")
							managers.hud:change_waypoint_arrow_color(obs_susp_data.icon_id, tweak_data.hud.detected_color)
							waypoint.bitmap:set_color(tweak_data.hud.detected_color)
						end
					end
				end
			end
		end
	end
end)
