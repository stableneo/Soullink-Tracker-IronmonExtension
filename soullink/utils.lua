utils = {
    -- default settings getting updated in runtime
    Settings = {
        ["showLevelCap"] = false,
        ["showLinkWarning"] = true
    },
    SettingDescriptions = {
        ["showLevelCap"] = "Show current level cap",
        ["showLinkWarning"] = "Activate link warning"
    },
    SaveFileName = "save.json"  -- default name, gets changed on load
}

local savesPath = ExtConstants.PATHS.soullink .. "saves" .. FileManager.slash
local settingsFilePath = ExtConstants.PATHS.soullink .. "Settings.ini"

local saveFilePath = savesPath

function utils.updateSaveFileName()
    local name = GameSettings.getRomName()
    local noSpaces = string.gsub(name, "%s+", "")
    local newSaveFileName = noSpaces .. ".json"
    saveFilePath = savesPath .. newSaveFileName
end

local bottomAreaPadding = Utils.inlineIf(
    TeamViewArea.isDisplayed(), 
    Constants.SCREEN.BOTTOM_AREA, 
    Constants.SCREEN.DOWN_GAP
)

-- Settings ini
function utils.loadSettings()
    local settings = nil

    local file = io.open(settingsFilePath)
    if file ~= nil then
        settings = Inifile.parse(file:read("*a"), "memory")
        io.close(file)
    end

    if settings == nil then return false end

    for configKey, _ in pairs(utils.Settings) do
        local configValue = settings.config[string.gsub(configKey, " ", "_")]
        if configValue ~= nil then
            utils.Settings[configKey] = configValue
        end
    end
end

function utils.saveSettings()
    local settings = {}
    settings.config = {}

    for configKey, _ in pairs(utils.Settings) do
		local encodedKey = string.gsub(configKey, " ", "_")
		settings.config[encodedKey] = utils.Settings[configKey]
	end

    Inifile.save(settingsFilePath, settings)
end

-- Toggles the boolean setting (optionKey) and returns the resulting value
function utils.toggleSetting(settingKey)
    if settingKey == nil then return end
	if type(utils.Settings[settingKey]) == "boolean" then
		utils.addUpdateSetting(settingKey, not utils.Settings[settingKey])
	end
	return utils.Settings[settingKey]
end

-- Updates the setting (optionKey) or if it doesn't exist, adds it. Then saves the change to the Settings.ini file
function utils.addUpdateSetting(settingKey, value)
	if settingKey == nil then return end
	utils.Settings[settingKey] = value
	utils.saveSettings()
end

-- ui
function utils.closeAllScreens()
end

function utils.updateUISpace()
    if not Main.IsOnBizhawk() then return end

    local extraSpace = 0

    if utils.Settings["showLinkWarning"] == true then
        extraSpace = ExtConstants.UI.INTS.soullinkSpaceExtended
    else
        extraSpace = ExtConstants.UI.INTS.soullinkSpace
    end

    client.SetGameExtraPadding(
        0,
        Constants.SCREEN.UP_GAP, 
        Constants.SCREEN.RIGHT_GAP, 
        bottomAreaPadding + extraSpace
    )
end

function utils.resetUISpace()
    if not Main.IsOnBizhawk() then return end

    client.SetGameExtraPadding(
        0,
        Constants.SCREEN.UP_GAP, 
        Constants.SCREEN.RIGHT_GAP, 
        bottomAreaPadding
    )
end

function utils.createChoosePokemonForm(func)
    if not func then return end 
    local form = ExternalUI.BizForms.createForm("Choose Pokémon", 360, 105)

    LinkHandler:checkAndUpdateAvailablePokemon()

    form:createLabel("Choose Pokémon to link", 49, 10)
    local pokedexDropdown = form:createDropdown(LinkHandler.remainingPokemon, 50, 30, 145, 30, nil)

    form:createButton("Choose Pokémon", 212, 29, function()
        local pokemonNameFromForm = ExternalUI.BizForms.getText(pokedexDropdown)
        local pokemonId = PokemonData.getIdFromName(pokemonNameFromForm)

        if pokemonId ~= nil and pokemonId ~= 0 then
            -- get pokemon object from id
            local data = DataHelper.buildPokemonInfoDisplay(pokemonId)
            func(data)
            Program.redraw(true)
        end
        form:destroy()
    end)
end

function utils.createChooseRouteForm(func)
    if not func then return end
    local form = ExternalUI.BizForms.createForm("Choose Route", 360, 105)

    form:createLabel("Choose a Route for the link:", 49, 10)

    LinkHandler:checkAndUpdateAvailableRoutes()

    local startItem = LinkHandler.remainingRoutes[1]
    local routeDropdown = form:createDropdown(LinkHandler.remainingRoutes, 50, 30, 145, 30, startItem, false)

    form:createButton("Choose Route", 212, 29, function()
        local dropdownSelection = ExternalUI.BizForms.getText(routeDropdown)
        local mapId

        for id, data in pairs(RouteData.Info) do
            local nameToMatch = Utils.formatSpecialCharacters(data.name)
            if nameToMatch == dropdownSelection then
                mapId = id
                break
            end
        end

        if mapId ~= nil and mapId ~= 0 then
            func(mapId)
            Program.redraw(true)
        end
        form:destroy()
    end)
end

-- json
function utils.saveJson()
    local links = LinkHandler:getLinks() or {}
    local bannedPokemon = LinkHandler:getBannedPokemon() or {}
    local bannedRoutes = LinkHandler:getBannedRoutes() or {}

    local data = {
        links = links,
        bannedPokemon = bannedPokemon,
        bannedRoutes = bannedRoutes,
    }
    
    local result = FileManager.encodeToJsonFile(saveFilePath, data)

    if ExtConstants.DEBUG then
        if result == true then
            print("")
            print("------")
            print(string.format("%s links saved", #links))
            print(string.format("%s banned Pokemon saved", #bannedPokemon))
            print(string.format("%s banned Routes saved", #bannedRoutes))
            print("------")
            print("")
        elseif result == false then
            print("Resulting json is empty")
        elseif result == nil then
            print("There was no save file to save to") 
        end
    end

    return result
end

function utils.loadJson()
    local decoded = FileManager.decodeJsonFile(saveFilePath) or {}

    if decoded == nil then
        print("There was no save file to load")
    end

    local links = decoded.links or {}
    local bannedPokemon = decoded.bannedPokemon or {}
    local bannedRoutes = decoded.bannedRoutes or {}

    LinkHandler:setLinks(links)
    LinkHandler:setBannedPokemon(bannedPokemon)
    LinkHandler:setBannedRoutes(bannedRoutes)

    if ExtConstants.DEBUG then
        print("")
        print("------")
        print(string.format("%s links loaded", #links))
        print(string.format("%s banned Pokemon loaded", #bannedPokemon))
        print(string.format("%s banned Routes loaded", #bannedRoutes))
        print("------")
        print("")
    end

    return true
end

function utils.deleteLinkByRouteId(routeId)
    if not routeId then return false end

    -- load current links
    local links = LinkHandler:getLinks() or {}
    if type(links) ~= "table" then return false end

    -- new table without deleted the link
    local newLinks = {}
    for _, link in ipairs(links) do
        if link.routeId ~= routeId then
            table.insert(newLinks, link)
        end
    end

    -- update LinkHandler links
    LinkHandler:setLinks(newLinks)
    return utils.saveJson()
end

function utils.deleteLinkByPokemonId(pokemonId)
    if not pokemonId then return false end

    -- load current links
    local links = LinkHandler:getLinks() or {}
    if type(links) ~= "table" then return false end

    -- new table without deleted the link
    local newLinks = {}
    for _, link in ipairs(links) do
        if link.leftId ~= pokemonId then
            table.insert(newLinks, link)
        elseif link.rightId ~= pokemonId then
            table.insert(newLinks, link)
        end
    end

    -- update LinkHandler links
    LinkHandler:setLinks(newLinks)
    return utils.saveJson()
end

return utils