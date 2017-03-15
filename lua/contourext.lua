local friendly_color = ContourExt._types.friendly.color
ContourExt._types.friendly.color = nil
   
local add_original = ContourExt.add
function ContourExt:add(type, ...)
  local setup = add_original(self, type, ...)
  if setup and setup.type == "friendly" then
      setup.color = setup.color or friendly_color
  end
  return setup
end