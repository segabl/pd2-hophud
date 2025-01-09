if HopHUD.settings.hide_content_updates then
	function MenuComponentManager:create_new_heists_gui()
		self:close_new_heists_gui()
	end
end

if HopHUD.settings.hide_news_feed then
	function MenuComponentManager:create_newsfeed_gui()
		self:close_newsfeed_gui()
	end
end
