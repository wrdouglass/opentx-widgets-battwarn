
local _options = {
    { "Switch", SOURCE, 115},
}

local function create(zone, options)
    return {zone=zone, options=options}
end

local function update(wgt, newOptions)
    wgt.options = newOptions
end

local function background(wgt)
end

local function refresh(wgt)
    local x = wgt.zone.x + wgt.zone.w/2 - 23;
    local y = wgt.zone.y + wgt.zone.h/2 - 10;

    -- requires >= 2.3.11
    local originalColor = lcd.getColor(TEXT_COLOR)

    if wgt.options.Switch == 0 then
        lcd.setColor(TEXT_COLOR, DARKGREY)
        lcd.drawText(x, y, "????")
    elseif getValue(wgt.options.Switch) < 0 then
        lcd.setColor(TEXT_COLOR, DARKGREY)
        lcd.drawText(x, y, "HOLD");
    else
        lcd.setColor(TEXT_COLOR, DARKRED)
        lcd.drawFilledRectangle(wgt.zone.x, wgt.zone.y, wgt.zone.w, wgt.zone.h, SOLID)

        lcd.setColor(TEXT_COLOR, WHITE)
        lcd.drawRectangle(wgt.zone.x, wgt.zone.y, wgt.zone.w, wgt.zone.h, SOLID)
        lcd.drawText(x, y, "HOLD");
    end

    lcd.setColor(TEXT_COLOR, originalColor)
end

return { name = "Hold", options = _options, create = create, update = update, background = background, refresh = refresh }
