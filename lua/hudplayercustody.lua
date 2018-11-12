local init_original = HUDPlayerCustody.init
function HUDPlayerCustody:init(...)
  init_original(self, ...)

  local custody_panel = self._hud_panel:child("custody_panel")
  local timer_msg = custody_panel:child("timer_msg")
  
  timer_msg:set_font_size(tweak_data.hud.name_label_font_size)
  local _, _, w, h = timer_msg:text_rect()
  timer_msg:set_h(h)
  timer_msg:set_top(56)

  self._timer:set_font_size(math.floor(tweak_data.hud.name_label_font_size * 1.5))
  local _, _, w, h = self._timer:text_rect()
  self._timer:set_h(h)
  self._timer:set_top(math.floor(timer_msg:bottom()))
end