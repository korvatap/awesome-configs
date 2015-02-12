-- a simple CPU temperatur widget using acpi-tools.
-- This is written in plain lua and should run on 
-- any awesome-version.
--
-- 

-- M is the returned object containing the function which gathers the information
local M = {}

function M.getTemp(mid, high)

    local temp_out = {}
    local fd = io.popen("acpi -t", "r") 
    local line = fd:read()

    while line do
        sensor_num = string.match(line, "Thermal (%d)")
        sensor_temp = string.match(line, "Thermal %d*:.* (%d*\.%d)")
        if tonumber(sensor_temp)>high then
            color = "<span color='#FF4000'>"
        elseif tonumber(sensor_temp)>mid then
            color = "<span color='#FF8000'>"
        else
            color = "<span color='#00FF80'>"
        end

        table.insert(temp_out, " #" .. sensor_num .. " at " .. color .. sensor_temp .. "</span>℃")
        
        --
        line = fd:read()
    end
    return table.concat(temp_out, " |")

end

return M
