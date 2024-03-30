-- Sniper Auto-fire v1.0.0
-- Klehrik

log.info("Successfully loaded ".._ENV["!guid"]..".")
Helper = require("./helper")

local init = false
local player = nil
local bar = nil
local first_pass = false    -- Allow reloading at any point after the first passthrough of the bar



-- ========== Main ==========

gm.pre_script_hook(gm.constants.__input_system_tick, function()
    -- Set Z skills to autofire
    if not init then
        init = true
        for i = 66, 71, 5 do
            gm.array_set(gm.variable_global_get("class_skill")[i], 12, false)
        end
    end


    if Helper.does_instance_exist(player) then
        -- Get Sniper reload bar belonging to this client
        if player.class == 7.0 then
            local _bar = Helper.find_active_instance_all(gm.constants.oSniperBar)
            if _bar then
                for i = 1, #_bar do
                    if _bar[i].parent.id == player.id then
                        bar = _bar[i]
                        if bar.position > 60.0 then first_pass = false end
                    end
                end
            else first_pass = true
            end
        end

    else player = Helper.get_client_player()
    end
end)


gm.pre_script_hook(gm.constants.skill_activate, function(self, other, result, args)
    -- Prevent reloading before the white zone (on first pass only)
    if self == player and args[1].value == 0.0 then
        if Helper.does_instance_exist(bar) then
            if bar.position < 17.0 and first_pass then return false end
        end
    end
end)