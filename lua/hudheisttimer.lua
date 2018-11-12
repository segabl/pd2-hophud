local init_original = HUDHeistTimer.init
function HUDHeistTimer:init(...)
  init_original(self, ...)

  self._timer_text:set_font(tweak_data.menu.pd2_large_font_id)
  self._timer_text:set_font_size(28)

  local _, _, _, th = self._timer_text:text_rect()
  self._realtime_text = self._heist_timer_panel:text({
    name = "realtime_text",
    text = "00:00",
    font_size = 18,
    font = tweak_data.hud.medium_font_noshadow,
    color = Color.white:with_alpha(0.8),
    align = "center",
    vertical = "top",
    y = th,
    layer = 1
  })
  local _, _, _, rh = self._realtime_text:text_rect()
  self._heist_timer_panel:set_h(self._heist_timer_panel:h() + rh)
end

local set_time_original = HUDHeistTimer.set_time
function HUDHeistTimer:set_time(time)
  if not self._enabled or math.floor(time) < self._last_time then
    return
  end
  set_time_original(self, time)
  self._realtime_text:set_text(os.date("%H:%M"))
end