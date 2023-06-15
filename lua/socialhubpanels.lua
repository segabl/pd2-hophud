local colors = {
	["in payday 2"] = Color(0.75, 1, 0.5),
	["in game"] = Color(0.75, 1, 0.5),
	["online"] = Color(0.5, 0.75, 1),
	["snooze"] = Color(0.35, 0.5, 0.75, 1),
	["away"] = Color(0.35, 0.5, 0.75, 1),
	["offline"] = Color(0.35, 1, 1, 1)
}

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

	self._state_text:set_color(colors[self.friend_data.state] or Color.white)
end)

function SocialHubUserItem:get_status_prio()
	if self.friend_data.state == "offline" then
		return 6
	elseif self.friend_data.state == "away" then
		return 5
	elseif self.friend_data.state == "snooze" then
		return 4
	elseif self.friend_data.state == "online" then
		return 3
	elseif self.friend_data.state == "in game" then
		return 2
	elseif self.friend_data.state == "in payday 2" then
		return 1
	end
	return 5
end
