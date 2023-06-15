function SocialHubManager:fetch_steam_friends(callback)
	self._platform_users = {}

	for _, item in ipairs(Steam:logged_on() and Steam:friends() or {}) do
		self:add_cached_user(item:id(), {
			display_name = item:name(),
			id = item:id(),
			lobby = item:lobby(),
			rich_presence = item:rich_presence(),
			state = item:playing_this() and "in payday 2" or item:playing_id() ~= 0 and "in game" or item:state(),
			account_type = Idstring("STEAM")
		})
		table.insert(self._platform_users, item:id())
	end

	if callback then
		callback()
	end
end
