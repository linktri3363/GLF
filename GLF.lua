_addon.name = 'GLF'
_addon.author = 'Linktri'
_addon.version = '1.1'
_addon.description = 'Detects "impossible to gauge" notorious monsters in Apollyon and Temenos'

require('logger')
local packets = require('packets')

-- Configuration
local enabled = true
local auto_check = false
local checking = false
local check_interval = 20
local last_check_time = 0

-- Zone IDs
local limbus_zones = {
    [37] = "Temenos West",
    [38] = "Apollyon"
}

-- Check if in limbus
local function is_in_limbus()
    local zone_id = windower.ffxi.get_info().zone
    return limbus_zones[zone_id] ~= nil
end

-- Get monsters - Try multiple detection methods
local function get_monsters()
    local monsters = {}
    
    -- Method 1: Standard mob array
    local mob_array = windower.ffxi.get_mob_array()
    windower.add_to_chat(8, '[GLF] Method 1 - Mob array length: ' .. (#mob_array or 0))
    
    -- Method 2: Try accessing mob array differently  
    local mob_table = windower.ffxi.get_mob_table()
    local mob_count = 0
    if mob_table then
        for id, mob in pairs(mob_table) do
            if mob then mob_count = mob_count + 1 end
        end
    end
    windower.add_to_chat(8, '[GLF] Method 2 - Mob table count: ' .. mob_count)
    
    -- Method 3: Try player's target as a test
    local player = windower.ffxi.get_player()
    if player and player.target_index and player.target_index > 0 then
        local target = windower.ffxi.get_mob_by_index(player.target_index)
        if target then
            windower.add_to_chat(8, '[GLF] Method 3 - Target detected: ' .. (target.name or 'Unknown'))
        end
    else
        windower.add_to_chat(8, '[GLF] Method 3 - No target')
    end
    
    -- Try the mob_table approach if mob_array is empty
    if #mob_array == 0 and mob_table then
        windower.add_to_chat(8, '[GLF] Using mob_table fallback...')
        for id, mob in pairs(mob_table) do
            if mob and mob.valid and mob.spawn_type == 16 and mob.hpp and mob.hpp > 0 then
                table.insert(monsters, mob)
                windower.add_to_chat(8, '[GLF] Valid mob: ' .. (mob.name or 'Unknown') .. ' (HP: ' .. mob.hpp .. '%)')
            end
        end
    end
    
    return monsters
end

-- Check specific monster
local function check_monster(mob_id)
    local mob = windower.ffxi.get_mob_by_id(mob_id)
    if not mob then return end
    
    local packet = packets.new('outgoing', 0x016, {
        ['Target'] = mob_id,
        ['Target Index'] = mob.index
    })
    packets.inject(packet)
end

-- Scan for NMs
local function scan_for_nm()
    windower.add_to_chat(8, '[GLF] Starting scan...')
    
    if not enabled then
        windower.add_to_chat(8, '[GLF] Disabled')
        return
    end
    
    if not is_in_limbus() then
        windower.add_to_chat(8, '[GLF] Not in Limbus')
        return
    end
    
    if checking then
        windower.add_to_chat(8, '[GLF] Already checking')
        return
    end
    
    checking = true
    local monsters = get_monsters()
    windower.add_to_chat(8, '[GLF] Found ' .. #monsters .. ' monsters')
    
    if #monsters == 0 then
        checking = false
        return
    end
    
    -- Check monsters one by one
    for i, mob in ipairs(monsters) do
        check_monster(mob.id)
        coroutine.sleep(1.5)
    end
    
    checking = false
    windower.add_to_chat(8, '[GLF] Scan complete')
end

-- Handle check results
windower.register_event('incoming chunk', function(id, data)
    if id == 0x00E then
        local packet = packets.parse('incoming', data)
        local message = packet['Message']
        
        if message and string.find(message, 'impossible to gauge') then
            local target_id = packet['Target']
            local mob = windower.ffxi.get_mob_by_id(target_id)
            if mob then
                windower.add_to_chat(13, '[GLF] *** NOTORIOUS MONSTER FOUND: ' .. (mob.name or 'Unknown') .. ' ***')
            end
        end
    end
end)

-- Auto-check timer
windower.register_event('time change', function()
    if not auto_check or not enabled then
        return
    end
    
    local current_time = os.time()
    if current_time - last_check_time >= check_interval then
        windower.add_to_chat(8, '[GLF] Auto-scan triggered')
        scan_for_nm()
        last_check_time = current_time
    end
end)
windower.register_event('addon command', function(command)
    windower.add_to_chat(8, '[GLF] Command: ' .. (command or 'nil'))
    
    if command == 'scan' then
        windower.add_to_chat(8, '[GLF] Manual scan triggered')
        scan_for_nm()
        
    elseif command == 'toggle' then
        enabled = not enabled
        windower.add_to_chat(8, '[GLF] ' .. (enabled and 'Enabled' or 'Disabled'))
        
    elseif command == 'status' then
        windower.add_to_chat(8, '[GLF] Status: ' .. (enabled and 'On' or 'Off'))
        windower.add_to_chat(8, '[GLF] Zone: ' .. windower.ffxi.get_info().zone)
        windower.add_to_chat(8, '[GLF] In Limbus: ' .. tostring(is_in_limbus()))
        
    elseif command == 'auto' then
        auto_check = not auto_check
        windower.add_to_chat(8, '[GLF] Auto-check ' .. (auto_check and 'enabled' or 'disabled'))
        
    elseif command == 'reset' then
        checking = false
        auto_check = false
        windower.add_to_chat(8, '[GLF] Reset complete')
        
    else
        windower.add_to_chat(8, '[GLF] Commands: scan, toggle, status, auto, reset')
    end
end)

-- Initialize
windower.add_to_chat(8, '[GLF] Loaded v1.1 - Zone: ' .. windower.ffxi.get_info().zone)