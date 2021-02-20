
local _options = {
    { "Sensor", SOURCE, 0},
    { "Cells", VALUE, 6, 1, 12 }, -- Defines the amount of lipo cells
}

local lastBatteryPercentage = 100

-- "borrowed" from Björn Pasteuning / Hobby4life 2019 BattPct
local function getPercentColor(cpercent)
    if cpercent < 30 then
        return lcd.RGB(0xff, 0, 0)
    else
        g = math.floor(0xdf * cpercent / 100)
        r = 0xdf - g
        return lcd.RGB(r, g, 0)
    end
end

-- "borrowed" from Björn Pasteuning / Hobby4life 2019 BattPct
local function getCellPercent(cellValue)
    local myArrayPercentList =
    {
        {3.000, 0}, {3.093, 1}, {3.196, 2}, {3.301, 3}, {3.401, 4}, {3.477, 5}, {3.544, 6}, {3.601, 7}, {3.637, 8}, {3.664, 9}, {3.679, 10}, {3.683, 11}, {3.689, 12}, {3.692, 13}, {3.705, 14}, {3.710, 15}, {3.713, 16}, {3.715, 17}, {3.720, 18}, {3.731, 19}, {3.735, 20}, {3.744, 21}, {3.753, 22}, {3.756, 23}, {3.758, 24}, {3.762, 25}, {3.767, 26},
        {3.774, 27}, {3.780, 28}, {3.783, 29}, {3.786, 30}, {3.789, 31}, {3.794, 32}, {3.797, 33}, {3.800, 34}, {3.802, 35}, {3.805, 36}, {3.808, 37}, {3.811, 38}, {3.815, 39}, {3.818, 40}, {3.822, 41}, {3.825, 42}, {3.829, 43}, {3.833, 44}, {3.836, 45}, {3.840, 46}, {3.843, 47}, {3.847, 48}, {3.850, 49}, {3.854, 50}, {3.857, 51}, {3.860, 52}, {3.863, 53}, {3.866, 54}, {3.870, 55}, {3.874, 56}, {3.879, 57},
        {3.888, 58}, {3.893, 59}, {3.897, 60}, {3.902, 61}, {3.906, 62}, {3.911, 63}, {3.918, 64}, {3.923, 65}, {3.928, 66}, {3.939, 67}, {3.943, 68}, {3.949, 69}, {3.955, 70}, {3.961, 71}, {3.968, 72}, {3.974, 73}, {3.981, 74}, {3.987, 75}, {3.994, 76}, {4.001, 77}, {4.007, 78}, {4.014, 79}, {4.021, 80}, {4.029, 81}, {4.036, 82}, {4.044, 83}, {4.052, 84}, {4.062, 85},
        {4.074, 86}, {4.085, 87}, {4.095, 88}, {4.105, 89}, {4.111, 90}, {4.116, 91}, {4.120, 92}, {4.125, 93}, {4.129, 94}, {4.135, 95}, {4.145, 96}, {4.176, 97}, {4.179, 98}, {4.193, 99}, {4.200, 100} 
    }
    
    if cellValue >= 4.2 then
        cellValue = 4.2
    elseif cellValue <= 3 then
        return 0
    end
    
    for i, v in ipairs( myArrayPercentList ) do
        if v[ 1 ] >= cellValue then
            return v[ 2 ]
        end
    end
    
    return 0
end

local function getBatteryPercent(wgt)
    local voltage = getValue(wgt.options.Source)/wgt.options.Cells
    local percentage = getCellPercent(voltage)
    
    return percentage
end

local function create(zone, options)
    return {zone=zone, options=options}
end

local function update(wgt, newOptions)
    wgt.options = newOptions
end

local lastBatteryLowAnnouncment = 0

function playBatteryLow()
    local differenceInMilliseconds = (getTime() - lastBatteryLowAnnouncment)*10

    if (differenceInMilliseconds > 10*1000) then
        playFile("batterylow.wav")
        lastBatteryLowAnnouncment = getTime()
    end
end

function warnIfNeeded(percentage)
    if lastBatteryPercentage > 80 and percentage <= 80 then
        playFile("battery80.wav")
    elseif lastBatteryPercentage > 60 and percentage <= 60 then
        playFile("battery60.wav")
    elseif lastBatteryPercentage > 40 and percentage <= 40 then
        playFile("battery40.wav")
    elseif percentage < 25 then 
        playBatteryLow()
    end

    lastBatteryPercentage = percentage
end

local function background(wgt)
    local percentage = getBatteryPercent(wgt)
    warnIfNeeded(percentage)
end

local function refresh(wgt)
    local x = wgt.zone.x + wgt.zone.w/2 - 14;
    local y = wgt.zone.y + wgt.zone.h/2 - 19;

    percentage = getBatteryPercent(wgt)

    -- requires >= 2.3.11
    local originalColor = lcd.getColor(TEXT_COLOR)

    lcd.setColor(TEXT_COLOR, getPercentColor(percentage));
    lcd.drawFilledRectangle(wgt.zone.x, wgt.zone.y, wgt.zone.w, wgt.zone.h, SOLID)

    lcd.setColor(TEXT_COLOR, WHITE)

    if percentage == 100 then
        lcd.drawText(x+5, y+10, "100%")
    elseif percentage < 10 then
        lcd.drawText(x+18,y, percentage, DBLSIZE)
        lcd.drawText(x+38, y+2, "%", SMLSIZE)
    else
        lcd.drawText(x,y, percentage, DBLSIZE)
        lcd.drawText(x+38, y+2, "%", SMLSIZE)
    end

    lcd.setColor(TEXT_COLOR, originalColor)

    local bx = wgt.zone.x + 2
    local by = wgt.zone.y + 6
    local bw = 17
    local bh = wgt.zone.h*.75

    local fh = bh - bh * (percentage/100)

    lcd.drawRectangle(bx+5, by-3, bw-10, 3)
    lcd.drawRectangle(bx, by, bw, bh)
    lcd.drawFilledRectangle(bx, by+fh, bw, bh-fh)

    warnIfNeeded(percentage)
end

return { name = "BattWarn", options = _options, create = create, update = update, background = background, refresh = refresh }
