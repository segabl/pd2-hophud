if HopHUD.settings.hide_content_updates then
	function NewHeistsGui:set_enabled()
		self._content_panel:set_visible(false)
	end
end
