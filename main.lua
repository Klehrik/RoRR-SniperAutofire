-- Item Toggle v1.0.5
-- Klehrik

log.info("Successfully loaded ".._ENV["!guid"]..".")
mods.on_all_mods_loaded(function() for k, v in pairs(mods) do if type(v) == "table" and v.hfuncs then Helper = v end end end)

local file_path = path.combine(paths.plugins_data(), "Klehrik-Item_Toggle-v2.txt")

local init = false

local rarity_toggles = {{}, {}, {}, {}, {}}
local rarity_names = {"Common", "Uncommon", "Rare", "Equipment", "Boss"}

local can_toggle = false
local rarity_to_check = 0



-- ========== Functions ==========

local function save_to_file()
    -- Save to file
    pcall(toml.encodeToFile, {
        white   = rarity_toggles[1],
        green   = rarity_toggles[2],
        red     = rarity_toggles[3],
        orange  = rarity_toggles[4],
        yellow  = rarity_toggles[5]
    }, {file = file_path, overwrite = true})
end


local function spawn_random_enabled(x, y, rarity)
    local enabled = {}
    local toggles = rarity_toggles[rarity]
    for k, v in pairs(toggles) do
        if v then
            table.insert(enabled, Helper.find_item(k).id)
        end
    end

    if #enabled <= 0 then return end
    gm.instance_create_depth(x, y, 0, enabled[gm.irandom_range(1, #enabled)])
end



-- ========== Main ==========

-- Loop through all rarities and add all item buttons
for r = 1, #rarity_names do
    gui.add_imgui(function()
        if init then
            if ImGui.Begin(rarity_names[r]) then
                local toggle = rarity_toggles[r]

                if not can_toggle then ImGui.Text("Items can only be\ntoggled on the character\nselect screen.") end

                if ImGui.Button("Enable All") and can_toggle then
                    for k in pairs(toggle) do toggle[k] = true end
                    save_to_file()
                elseif ImGui.Button("Disable All") and can_toggle then
                    for k in pairs(toggle) do toggle[k] = false end
                    save_to_file()
                end

                ImGui.Text("")

                local items = Helper.get_all_items(r)
                for i = 1, #items do
                    local c = "  "
                    if toggle[items[i].localization] then c = "v" end
                    if ImGui.Button("["..c.."]  "..items[i].name) and can_toggle then
                        toggle[items[i].localization] = not toggle[items[i].localization]
                        save_to_file()
                    end
                end
            end
        end

        ImGui.End()
    end)
end


gm.pre_script_hook(gm.constants.__input_system_tick, function()
    -- Initialize
    if not init then
        init = true

        for i = 1, #rarity_toggles do
            local items = Helper.get_all_items(i)
            for j = 1, #items do
                rarity_toggles[i][items[j].localization] = true
            end
        end

        -- Load from file
        local succeeded, from_file = pcall(toml.decodeFromFile, file_path)
        if succeeded then
            rarity_toggles = {
                from_file.white,
                from_file.green,
                from_file.red,
                from_file.orange,
                from_file.yellow
            }
        end
    end


    -- Check if on CSS
    local selectM = Helper.find_active_instance(gm.constants.oSelectMenu)
    if Helper.instance_exists(selectM) then can_toggle = true
    else can_toggle = false
    end


    -- Check for all items of a different rarity
    -- split into every frame to reduce load
    rarity_to_check = rarity_to_check + 1
    if rarity_to_check > #rarity_toggles then rarity_to_check = 1 end

    local item_tables = Helper.get_all_items(rarity_to_check)

    for i = 1, #item_tables do
        local current = item_tables[i]
        local items = Helper.find_active_instance_all(current.id)
        for j = 1, #items do

            local inst = items[j]
            
            if not rarity_toggles[rarity_to_check][inst.text1_key] then
                spawn_random_enabled(inst.x, inst.y, rarity_to_check)
                gm.instance_destroy(inst)
            end
            
        end
    end
end)