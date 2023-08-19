-- User Settings

local Activate_Key = "capslock"
local Auto_ADS_Key = "scrolllock"

local Fire_key = 1
local ADS_key = 3
local Weapon_switch_key = 9

weapon_table = {
    mira = { Horizontal = -0.1, Vertical = 5.0, FireDelay = 7, AdsDelay = 300 },
    fuze = { Horizontal = -0.3, Vertical = 5.9, FireDelay = 7, AdsDelay = 300 },
    maestro = { Horizontal = -0.2, Vertical = 3.1, FireDelay = 7, AdsDelay = 300 },
    fenrir = { Horizontal = -0.1, Vertical = 4.2, FireDelay = 7, AdsDelay = 300 }
}

local current_weapon = "mira" -- The Recoil-pattern you want to be activated on the start

-- Other Settings

local VERSION = "3.0.4"
local script_active = true
local function PrintCentered(text)
    local consoleWidth = 80  -- Adjust this to the width of your console if needed
    local borderChar = '-'   -- Character for the border
    local border = string.rep(borderChar, consoleWidth)

    OutputLogMessage('%s\n', border)
    OutputLogMessage('| %-76s |\n', '')  -- Empty line for spacing
    OutputLogMessage('| %-76s |\n', text)
    OutputLogMessage('| %-76s |\n', '')  -- Empty line for spacing
    OutputLogMessage('%s\n', border)
end

-- Random Coefficient generator

function Volatility(range, impact)
    return range * (1 + impact * math.random())
end

-- Move mouse by X and Y

-- Move mouse by X
function Move_x(_horizontal_recoil)
    local x_recoil = math.floor(Volatility(0.7, 1) * _horizontal_recoil)
    MoveMouseRelative(x_recoil, 0) -- 70 ~ 140 %
end

-- Move mouse by y
function Move_y(_vertical_recoil)
    local y_recoil = math.floor(Volatility(0.7, 1) * _vertical_recoil)
    MoveMouseRelative(0, y_recoil) -- 70 ~ 140 %
end


function Direct_Fire()
--SomeUndefinedFunction()
    local horizontal_recoil = weapon_table[current_weapon]["Horizontal"]
    local vertical_recoil = weapon_table[current_weapon]["Vertical"]

    local float_x = math.abs(horizontal_recoil) - math.floor(math.abs(horizontal_recoil))
    local float_y = math.abs(vertical_recoil) - math.floor(math.abs(vertical_recoil))

    local i = 0
    local j = 0

    repeat
        -- move mouse by integer value of horizontal and vertical recoil
        if horizontal_recoil ~= 0 then
            if horizontal_recoil < 0 then
                Move_x(horizontal_recoil + float_x)
            else
                Move_x(vertical_recoil - float_x)
            end
        end

        if vertical_recoil ~= 0 then
            if vertical_recoil < 0 then
                Move_y(vertical_recoil + float_y)
            else
                Move_y(vertical_recoil - float_y)
            end
        end

        if float_x ~= 0 then
            i = i + float_x -- count until 1
            if i >= 1 * Volatility(0.7, 1) then
                local move_amount = horizontal_recoil > 0 and 1 or -1
                Move_x(move_amount)
                i = 0
            end
        end
        if float_y ~= 0 then
            j = j + float_y
            if j >= 1 * Volatility(0.1, 1) then
                local move_amount = vertical_recoil > 0 and 1 or -1
                Move_y(move_amount)
                j = 0
            end
        end

        Sleep(math.floor(Volatility(0.8, 0.5) * weapon_table[current_weapon]["FireDelay"])) -- 80 ~ 120 %

    until not IsMouseButtonPressed(Fire_key)
end

function ADS_Fire()
    PressMouseButton(ADS_key)
    Sleep(weapon_table[current_weapon]["AdsDelay"])
    Direct_Fire()
    ReleaseMouseButton(ADS_key)
    Sleep(40)
end

function FormatInfoSections()
    return {
        "",
        "Welcome to Anti-Recoil Update: " .. VERSION,
        "By: kebab_420",
    }
end

function FormatSettingsSections()
    return {
        { title = "Standard weapon:", value = current_weapon },
        { title = "Weapon switch:", value = "G" .. Weapon_switch_key },
        { title = "Auto ADS:", value = Auto_ADS_Key },
        { title = "Activate Key:", value = Activate_Key }
    }
end

function Initialize()
    ClearLog()
    local consoleWidth = 60  -- Adjust this to the width of your console if needed
    local borderChar = '-'   -- Character for the border
    local doubleBorderChar = '=' -- Character for the double border
    local verticalDoubleLineChar = '|' -- Character for the vertical double line
    local border = string.rep(borderChar, consoleWidth)
    local doubleBorder = string.rep(doubleBorderChar, consoleWidth)
    local verticalDoubleLine = verticalDoubleLineChar .. string.rep(' ', consoleWidth - 2) .. verticalDoubleLineChar
    local infoSections = FormatInfoSections()
    local settingsSections = FormatSettingsSections()
    OutputLogMessage("%s\n", doubleBorder)  -- Double line before the activation section
    for i = 1, math.max(#infoSections, #settingsSections) do
        local infoSection = infoSections[i] and infoSections[i] or ""
        OutputLogMessage("|| %-54s ||\n", infoSection)
    end
    OutputLogMessage("%s\n", doubleBorder)  -- Double line before the activation section

    for i = 1, #settingsSections do
        local section = settingsSections[i]
        local settingsSection = section and section.title and section.value and ("%s - %s"):format(section.title, section.value) or ""
        OutputLogMessage("|| %-54s ||\n", settingsSection)
    end
    OutputLogMessage("%s\n", doubleBorder)  -- Double line before the activation section
    OutputLogMessage("|| %-54s ||\n","")
    OutputLogMessage("|| %-54s ||\n","THIS SCRIPT WAS CREATED FOR EDUCATIONAL PURPOSES ONLY!")
    OutputLogMessage("|| %-54s ||\n","DO NOT MISUSE THIS IN GAMES TO GAIN ANY ADVANTAGE!!!")
    OutputLogMessage("|| %-54s ||\n","")
    OutputLogMessage("%s\n", doubleBorder)  -- Double line before the activation section
end


Initialize()

-- Error handler

function ErrorHandler(errorMessage)
    OutputLogMessage("Error: %s\n", errorMessage)
    Sleep(500)  -- Sleep for 2 seconds to give the user a chance to read the error message
end

-- Script loop

function OnEvent(event, arg)
    local success, error_message = pcall(function()

        if (event == "PROFILE_ACTIVATED") then
            EnablePrimaryMouseButtonEvents(true)
        elseif event == "PROFILE_DEACTIVATED" then
            ReleaseMouseButton(Fire_key)
            ReleaseMouseButton(ADS_key)
        end

            if IsKeyLockOn(Activate_Key) then
                if not script_active then
                    script_active = true
                    PrintCentered('* Script is now active *')
                end

                if (event == "MOUSE_BUTTON_PRESSED" and arg == Weapon_switch_key) then             
                    if current_weapon == "mira" then
                        current_weapon = "fuze"
                        OutputLogMessage('Fuze (ak-12) weapon profile activated...\n')  
                    elseif current_weapon == "fuze" then
                        current_weapon = "maestro"
                        OutputLogMessage('Maestro (alda) weapon profile activated...\n')  
                    elseif current_weapon == "maestro" then
                        current_weapon = "fenrir"
                        OutputLogMessage('Fenrir (MP7) weapon profile activated...\n')
                    elseif current_weapon == "fenrir" then
                        current_weapon = "mira"
                        OutputLogMessage('Mira (vector) weapon profile activated...\n')
                    end    
                end

                if (event == "MOUSE_BUTTON_PRESSED" and arg == Fire_key) then        
                    if IsKeyLockOn(Auto_ADS_Key) then 
                        ADS_Fire()
                    else
                        Direct_Fire()
                    end  
                end  

            else
                if script_active == true then
                    script_active = false
                    PrintCentered('* Script is now off *')
                end 
            end 
    end)
    
    -- Constant Variables
    local LINE_SEPARATOR = "-------------------------------------------------"
    local DETAILS_HEADER = "OOPS, IT LOOKS LIKE SOMETHING BROKE:"
    local END_FOOTER = "END OF THE ERROR"
    
    -- Customizable Contact Information
    local CONTACT_INFO = "If you didn't make any changes yourself, please contact kebab_420 on Discord!"
    
    -- Display a well-formatted error message
    if not success then
        -- Display a header with a separator
        local function DisplayHeader(headerText)
            ErrorHandler(LINE_SEPARATOR)
            ErrorHandler(headerText)
            ErrorHandler(LINE_SEPARATOR)
        end
    
        -- Display a section header and content with an empty line separator
        local function DisplaySection(sectionHeader, sectionContent)
            DisplayHeader(sectionHeader)
            ErrorHandler(sectionContent)
        end
    
        -- Display Error Details
        DisplaySection(DETAILS_HEADER, "")
        ErrorHandler("Error Details: " .. error_message)
    
        -- Display Contact Information
        ErrorHandler(CONTACT_INFO)
        ErrorHandler("")
    
        -- Display End Footer
        DisplayHeader(END_FOOTER)
    end
end