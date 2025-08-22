local SettingsScreen = dofile(ExtConstants.PATHS.screens .. "SettingsScreen.lua")
local OverviewScreen = dofile(ExtConstants.PATHS.screens .. "OverviewScreen.lua")
local LinkScreen = dofile(ExtConstants.PATHS.screens .. "LinkScreen.lua")
local BanlistScreen = dofile(ExtConstants.PATHS.screens .. "BanlistScreen.lua")
local MainButtonsScreen = dofile(ExtConstants.PATHS.screens .. "MainButtonsScreen.lua")

ScreenHandler = {
    SCREENS = {
        ["Main"]        = { isDisplayed = false, screen = MainButtonsScreen },
        ["Link"]        = { isDisplayed = false, screen = LinkScreen },
        ["Overview"]    = { isDisplayed = false, screen = OverviewScreen },
        ["Banlist"]     = { isDisplayed = false, screen = BanlistScreen },
        ["Settings"]    = { isDisplayed = false, screen = SettingsScreen },
    }
}

function ScreenHandler:toggleScreen(screenKey)
    if not self:keyExists(screenKey) then return false end

    if screenKey == "Overview" then
        OverviewScreen:buildPagedButtons()
    elseif screenKey == "Banlist" then
        BanlistScreen:buildPagedButtons()
    end

    if self.SCREENS[screenKey].isDisplayed == false then
        self:show(screenKey)
    else
        self:close(screenKey)
    end

    self:toggleTimer()
end

function ScreenHandler:show(screenKey)
    for key, info in pairs(self.SCREENS) do
        -- hide all other screens
        if screenKey ~= key then
            info.isDisplayed = false
        else
            info.isDisplayed = true
            Program.openOverlayScreen(info.screen, true)
        end
    end
end

function ScreenHandler:close(screenKey)
    for key, info in pairs(self.SCREENS) do
        if screenKey == key then
            info.isDisplayed = false
            Program.closeScreenOverlay()
            Program.redraw(true)
        end
    end
end

function ScreenHandler:renderMainButtons()
    self.SCREENS["Main"].screen.drawScreen()
end

-- hook up input handlers with this
function ScreenHandler:hookInput(screenKey, xmouse, ymouse)
    if self:keyExists(screenKey) == false then return end
    self.SCREENS[screenKey].screen.checkInput(xmouse, ymouse)
end

function ScreenHandler:hookEvent(screenKey, methodName)
    if self:keyExists(screenKey) == false then return end
    local screen = self.SCREENS[screenKey].screen
    local fn = screen[methodName]
    if type(fn) == "function" then
        fn(screen)
        return true
    end
    return false
end

function ScreenHandler:isDisplayed(screenKey)
    for key, info in pairs(self.SCREENS) do
        if screenKey == key then
            return info.isDisplayed
        end
    end

    return false
end

function ScreenHandler:toggleTimer()
    local timer = Program and Program.GameTimer
    if not timer then return end

    -- one screen must be rendered
    local anyDisplayed = false
    for _, info in pairs(self.SCREENS) do
        if info.isDisplayed then
            anyDisplayed = true
            break
        end
    end
    if displayed == false then return end

    if anyDisplayed then
        if not timer.isPaused then
            timer:pause()
        end
    else
        if timer.isPaused then
            timer:unpause()
        end
    end

    return true
end

function ScreenHandler:keyExists(screenKey)
    if self.SCREENS[screenKey] == nil then
        return false
    end

    return true
end

return ScreenHandler