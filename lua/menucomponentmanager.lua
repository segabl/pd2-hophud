local panel_padding = 12
local font = tweak_data.menu.pd2_medium_font
local font_size = tweak_data.menu.pd2_small_font_size

local SPOT_W = 32
local SPOT_H = 8
local BAR_W = 32
local BAR_H = 6
local BAR_X = (SPOT_W - BAR_W) / 2
local BAR_Y = 0

function BLTNotificationsGui:_setup()

  self._enabled = true

  -- Get player profile panel
  local profile_panel = managers.menu_component._player_profile_gui._panel

  -- Create panels
  self._panel = self._ws:panel():panel({
    w = profile_panel:w(),
    h = font_size * 4 + panel_padding * 2
  })
  self._panel:set_left(profile_panel:left())
  self._panel:set_bottom(profile_panel:top())

  self._content_panel = self._panel:panel({
    h = self._panel:h() * 0.8,
  })

  self._buttons_panel = self._panel:panel({
    h = self._panel:h() * 0.2,
  })
  self._buttons_panel:set_top(self._content_panel:h())

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
  BoxGuiObject:new(self._content_panel, { sides = { 1, 1, 1, 1 } })
  self._content_outline = BoxGuiObject:new(self._content_panel, { sides = { 2, 2, 2, 2 } })

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
  self:set_bar_width(BAR_W, true)
  self._bar:set_visible(false)

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

  self._downloads_panel:set_visible(false)

  -- Move other panels to fit the downloads notification in nicely
  self._panel:set_w(self._panel:w() + 24)
  self._panel:set_h(self._panel:h() + 24)
  self._panel:set_top(self._panel:top() - 24)
  self._content_panel:set_top(self._content_panel:top() + 24)
  self._buttons_panel:set_top(self._buttons_panel:top() + 24)

  self._downloads_panel:set_righttop(self._panel:w() - 10, 10)

  -- Add notifications that have already been registered
  for _, notif in ipairs(BLT.Notifications:get_notifications()) do
    self:add_notification(notif)
  end

  -- Check for updates when creating the notification UI as we show the check here
  BLT.Mods:RunAutoCheckForUpdates()

end