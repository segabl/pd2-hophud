local panel_padding = 12
local font = tweak_data.menu.pd2_medium_font
local font_size = tweak_data.menu.pd2_small_font_size

function BLTNotificationsGui:_setup()

  self._enabled = true

  -- Get player profile panel
  local profile_panel = managers.menu_component._player_profile_gui._panel

  -- Create panels
  self._panel = self._ws:panel():panel({
    w = profile_panel:w(),
    h = font_size * 4 + panel_padding * 2
  })
  self._panel:set_left( profile_panel:left() )
  self._panel:set_bottom( profile_panel:top() )
  -- BoxGuiObject:new( self._panel:panel({ layer = 100 }), { sides = { 1, 1, 1, 1 } } )

  self._content_panel = self._panel:panel({
    h = self._panel:h() * 0.8,
  })

  self._buttons_panel = self._panel:panel({
    h = self._panel:h() * 0.2,
  })
  self._buttons_panel:set_top( self._content_panel:h() )

  -- Blur background
  local bg_rect = self._content_panel:rect({
    name = "background",
    color = Color.black,
    alpha = 0.4,
    layer = -1,
    halign = "scale",
    valign = "scale"
  })

  local blur = self._content_panel:bitmap({
    texture = "guis/textures/test_blur_df",
    w = self._content_panel:w(),
    h = self._content_panel:h(),
    render_template = "VertexColorTexturedBlur3D",
    layer = -1,
    halign = "scale",
    valign = "scale"
  })

  -- Outline
  BoxGuiObject:new( self._content_panel, { sides = { 1, 1, 1, 1 } } )
  self._content_outline = BoxGuiObject:new( self._content_panel, { sides = { 2, 2, 2, 2 } } )

  -- Setup notification buttons
  self._bar = self._buttons_panel:bitmap({
    texture = "guis/textures/pd2/shared_lines",
    halign = "grow",
    valign = "grow",
    wrap_mode = "wrap",
    x = BAR_X,
    y = BAR_Y,
    w = BAR_W,
    h = BAR_H
  })
  self:set_bar_width( BAR_W, true )
  self._bar:set_visible( false )

  -- Downloads notification
  self._downloads_panel = self._panel:panel({
    name = "downloads",
    w = 28,
    h = 28,
    layer = 100
  })

  self._downloads_panel:bitmap({
    texture = "guis/textures/menu_ui_icons",
    texture_rect = {93, 2, 32, 32},
    w = self._downloads_panel:w(),
    h = self._downloads_panel:h(),
    color = Color.red
  })

  self._downloads_count = self._downloads_panel:text({
    font_size = font_size,
    font = font,
    layer = 10,
    blend_mode = "add",
    color = tweak_data.screen_colors.title,
    text = "2",
    align = "center",
    vertical = "center",
  })

  self._downloads_panel:set_visible( false )

  -- Move other panels to fit the downloads notification in nicely
  self._panel:set_w( self._panel:w() + 24 )
  self._panel:set_h( self._panel:h() + 24 )
  self._panel:set_top( self._panel:top() - 24 )
  self._content_panel:set_top( self._content_panel:top() + 24 )
  self._buttons_panel:set_top( self._buttons_panel:top() + 24 )

  self._downloads_panel:set_righttop(self._panel:w() - 10, 10)

  -- Add notifications that have already been registered
  for _, notif in ipairs( BLT.Notifications:get_notifications() ) do
    self:add_notification( notif )
  end

  -- Check for updates when creating the notification UI as we show the check here
  BLT.Mods:RunAutoCheckForUpdates()
  
  if BeardLib then
    self._beardlib_updates = self._panel:panel({
      name = "BeardLibModsManagerPanel",
      layer = 110, 
      w = 28,
      h = 28,
      y = 8,
    })
    self._beardlib_updates:set_righttop(self._content_panel:right() - 2, self._content_panel:top() + 2)
    local icon = self._beardlib_updates:bitmap({
      name = "Icon",
      texture = "guis/textures/menu_ui_icons",
      texture_rect = {93, 2, 32, 32},
      w = 28,
      h = 28,
      color = Color(0, 0.4, 1),
      rotation = 360
    })
    self._beardlib_updates:text({
      name = "UpdatesCount",
      font_size = font_size,
      rotation = 360,
      font = font,
      layer = 10,
      color = tweak_data.screen_colors.title,
      text = "0",
      align = "center",
      vertical = "center"
    }):set_center(icon:center())
  end
  
end

local update_original = BLTNotificationsGui.update
function BLTNotificationsGui:update(...)
  update_original(self, ...)
  if alive(self._beardlib_updates) then
    local count = self._beardlib_updates:child("UpdatesCount")
    if alive(count) then
      self._beardlib_updates:set_visible(#BeardLib.managers.mods_menu._waiting_for_update > 0)
      if not self._downloads_panel:visible() then
        self._beardlib_updates:set_righttop(self._downloads_panel:right(), self._downloads_panel:top())
      else
        self._beardlib_updates:set_righttop(self._content_panel:right() - 2, self._content_panel:top() + 2)
      end
    end
  end
end

function BLTNotificationsGui:add_notification(parameters)

  -- Create notification panel
  local new_notif = self._content_panel:panel({})

  local icon_size = font_size * 3
  local icon
  if parameters.icon then
    icon = new_notif:bitmap({
      texture = parameters.icon,
      texture_rect = parameters.icon_texture_rect,
      color = parameters.color or Color.white,
      alpha = parameters.alpha or 1,
      x = panel_padding,
      y = panel_padding,
      w = icon_size,
      h = icon_size,
    })
  end

  local _x = (icon and icon:right() or 0) + panel_padding

  local title = new_notif:text({
    text = parameters.title or "No Title",
    font = font,
    font_size = font_size,
    x = _x,
    y = panel_padding,
  })
  self:_make_fine_text( title )

  local text = new_notif:text({
    text = parameters.text or "No Text",
    font = font,
    font_size = font_size,
    x = _x,
    w = new_notif:w() - _x,
    y = title:bottom(),
    h = new_notif:h() - title:bottom(),
    color = tweak_data.screen_colors.text:with_alpha(0.65),
    wrap = true,
    word_wrap = true,
  })

  -- Create notification data
  local data = {
    id = self:_get_uid(),
    priority = parameters.priority or 0,
    parameters = parameters,
    panel = new_notif,
    title = title,
    text = text,
    icon = icon,
  }

  -- Update notifications data
  table.insert( self._notifications, data )
  table.sort( self._notifications, function(a, b)
    return a.priority > b.priority
  end )
  self._notifications_count = table.size( self._notifications )

  -- Check notification visibility
  for i, notif in ipairs( self._notifications ) do
    notif.panel:set_visible( i == 1 )
  end
  self._current = 1

  self:_update_bars()

  return data.id

end