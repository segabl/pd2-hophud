Hooks:PostHook(SocialHubUserItem, "setup_panel", "setup_panel_effort", function (self)
	local icon = self._content_panel:child(0)
	if not icon then
		return
	end

	if Steam and self.friend_data.platform == Idstring("STEAM") then
		Steam:friend_avatar(Steam.SMALL_AVATAR, self.friend_data.id, function (texture)
			if alive(icon) then
				icon:set_image(texture)
			end
		end)
	end

	if not self._state_text then
		return
	end

	local loc_id = "menu_hophud_friend_state_" .. self.friend_data.state
	self._state_text:set_text(managers.localization:exists(loc_id) and managers.localization:to_upper_text(loc_id) or utf8.to_upper(self.friend_data.state))
	ExtendedPanel.make_fine_text(self._state_text)
	self._state_text:set_right(self._right_side_panel:right() - self.type_config.margin)
	self._state_text:set_color(HopHUD.colors[self.friend_data.state] or HopHUD.colors.default)
end)

local priorities = {
	offline = 5,
	away = 4,
	snooze = 3,
	online = 1,
	in_game = 0,
	in_payday = -1
}
Hooks:OverrideFunction(SocialHubUserItem, "get_status_prio", function (self)
	return priorities[self.friend_data.state] or 4
end)
