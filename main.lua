-- Sniper Auto-fire v1.0.1
-- Klehrik

log.info("Successfully loaded ".._ENV["!guid"]..".")
mods.on_all_mods_loaded(function() for k, v in pairs(mods) do if type(v) == "table" and v.hfuncs then Helper = v end end end)

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


    if Helper.instance_exists(player) then
        -- Get Sniper reload bar belonging to this client
        if player.class == 7.0 then
            local bars, has = Helper.find_active_instance_all(gm.constants.oSniperBar)
            if has then
                for i = 1, #bars do
                    if bars[i].parent.id == player.id then
                        bar = bars[i]
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
        if Helper.instance_exists(bar) then
            if bar.position < 17.0 and first_pass then return false end
        end
    end
end)