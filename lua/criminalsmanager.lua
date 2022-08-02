if not HopHUD.settings.bot_colors then
	return
end

local taken_colors = {}

local character_color_id_by_unit_original = CriminalsManager.character_color_id_by_unit
function CriminalsManager:character_color_id_by_unit(unit)
	if managers.groupai and managers.groupai:state():is_unit_team_AI(unit) then
		local name = unit:base()._tweak_table
		if not taken_colors[name] then
			local taken_ids = {}
			for id, peer in ipairs(LuaNetworking:GetPeers()) do
				taken_colors[peer:character()] = id
			end
			for _, id in pairs(taken_colors) do
				taken_ids[id] = true
			end
			for id = CriminalsManager.MAX_NR_CRIMINALS, 2, -1 do
				if not taken_ids[id] then
					taken_colors[name] = id
					break
				end
			end
		end
		return taken_colors[name] or #tweak_data.chat_colors
	end
	return character_color_id_by_unit_original(self, unit)
end

Hooks:PostHook(CriminalsManager, "remove_character_by_name", "remove_character_by_name_hophud", function (self, name)
	taken_colors[name] = nil
end)
