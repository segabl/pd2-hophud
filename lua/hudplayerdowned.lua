local init_original = HUDPlayerDowned.init
function HUDPlayerDowned:init(...)
  init_original(self, ...)

  local downed_panel = self._hud_panel:child("downed_panel")
  local timer_msg = downed_panel:child("timer_msg")
  
  timer_msg:set_font_size(tweak_data.hud.name_label_font_size)
  local _, _, w, h = timer_msg:text_rect()
  timer_msg:set_h(h)
  timer_msg:set_top(56)

  self._hud.timer:set_font_size(math.floor(tweak_data.hud.name_label_font_size * 1.5))
  local _, _, w, h = self._hud.timer:text_rect()
  self._hud.timer:set_h(h)
  self._hud.timer:set_top(math.floor(timer_msg:bottom()))

  self._hud.arrest_finished_text:set_font_size(tweak_data.hud.name_label_font_size)
  local _, _, w, h = self._hud.arrest_finished_text:text_rect()
  self._hud.arrest_finished_text:set_h(h)
  self._hud.arrest_finished_text:set_top(56)
end