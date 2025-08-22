SettingsScreen = {
    Key = "Settings"
}

SettingsScreen.Buttons = {
    Close = {
        type = Constants.ButtonTypes.PIXELIMAGE,
        image = Constants.PixelImages.CLOSE,
        iconColors = { ExtConstants.UI.COLORS.text },
        box = { Constants.SCREEN.WIDTH - 11, 2, 10, 10 },
        onClick = function() ScreenHandler:toggleScreen(SettingsScreen.Key) end,
    }
}

function SettingsScreen.drawScreen()
    if not ScreenHandler:isDisplayed(SettingsScreen.Key) then return end

    -- pause timer
    if Program.GameTimer and not Program.GameTimer.isPaused then
        Program.GameTimer:pause()
    end

    Drawing.drawBackgroundAndMargins(0, 0, Constants.SCREEN.WIDTH, Constants.SCREEN.HEIGHT, ExtConstants.UI.COLORS.background)
    Drawing.drawText(5, 5, "Soullink Settings", ExtConstants.UI.COLORS.text)

    -- render buttons
    for _, b in pairs(SettingsScreen.Buttons) do
        Drawing.drawButton(b)
    end
end

function SettingsScreen.initialize()
    SettingsScreen.createButtons()
end

-- USER INPUT FUNCTIONS
function SettingsScreen.checkInput(xmouse, ymouse)
    Input.checkButtonsClicked(xmouse, ymouse, SettingsScreen.Buttons)
end

function SettingsScreen.createButtons()
    local x = 5
    local y = 30

    for settingKey, state in pairs(utils.Settings) do
        local label = utils.SettingDescriptions[settingKey]
        local textLength = #label

        local checkBox = {
            type = Constants.ButtonTypes.CHECKBOX,
            settingKey = settingKey,
            textColor = "Default text",
            box = { x, y, 8, 8 },
            boxColors = { "Upper box border", "Upper box background" },
            toggleState = state,
            isVisible = function() return true end,
            getText = function() return label end,
            onClick = function(this)
                this.toggleState = utils.toggleSetting(this.settingKey)

                if this.settingKey == "showLinkWarning" then
                    utils.updateUISpace()
                end

                -- save to Settings.ini
                utils.saveSettings()

                Program.redraw(true)
            end
        }

        table.insert(SettingsScreen.Buttons, checkBox)

        y = y + 15
    end
end

return SettingsScreen