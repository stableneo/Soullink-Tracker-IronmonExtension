MainButtonsScreen = {
    Key = "Main",
    enemyPokemon = nil,
}

local bottomAreaPadding = Utils.inlineIf(
    TeamViewArea.isDisplayed(), 
    Constants.SCREEN.BOTTOM_AREA, 
    Constants.SCREEN.DOWN_GAP
)

MainButtonsScreen.Buttons = {
    OpenOverview = {
        type = Constants.ButtonTypes.ICON_BORDER,
        image = Constants.PixelImages.POKEBALL,
        iconColors = TrackerScreen.PokeBalls.ColorList,
        box = { 
            0, 
            Constants.SCREEN.HEIGHT + bottomAreaPadding + ExtConstants.UI.INTS.gap, 
            ExtConstants.UI.INTS.buttonW, 
            ExtConstants.UI.INTS.buttonH 
        },
        getText = function() return OverviewScreen.Description end,
        onClick = function() ScreenHandler:toggleScreen(OverviewScreen.Key) end,
    },
    CreateLink = {
        type = Constants.ButtonTypes.ICON_BORDER,
        image = Constants.PixelImages.POKEBALL,
        iconColors = TrackerScreen.PokeBalls.ColorList,
        box = { 
            ExtConstants.UI.INTS.buttonW + ExtConstants.UI.INTS.gap, 
            Constants.SCREEN.HEIGHT + bottomAreaPadding + ExtConstants.UI.INTS.gap, 
            ExtConstants.UI.INTS.buttonW, 
            ExtConstants.UI.INTS.buttonH 
        },
        getText = function() return LinkScreen.Description end,
        onClick = function() ScreenHandler:toggleScreen(LinkScreen.Key) end,
    },
    BanList = {
        type = Constants.ButtonTypes.ICON_BORDER,
        image = Constants.PixelImages.POKEBALL,
        iconColors = TrackerScreen.PokeBalls.ColorList,
        box = { 
            ExtConstants.UI.INTS.buttonW * 2 + ExtConstants.UI.INTS.gap * 2, 
            Constants.SCREEN.HEIGHT + bottomAreaPadding + ExtConstants.UI.INTS.gap, 
            ExtConstants.UI.INTS.buttonW, 
            ExtConstants.UI.INTS.buttonH 
        },
        getText = function() return BanlistScreen.Description end,
        onClick = function() ScreenHandler:toggleScreen(BanlistScreen.Key) end,
    },
    Levelcap = {
        type = Constants.ButtonTypes.ICON_BORDER,
        image = Constants.PixelImages.POKEBALL,
        iconColors = TrackerScreen.PokeBalls.ColorList,
        box = { 
            ExtConstants.UI.INTS.buttonW * 3 + ExtConstants.UI.INTS.gap * 3, 
            Constants.SCREEN.HEIGHT + bottomAreaPadding + ExtConstants.UI.INTS.gap, 
            ExtConstants.UI.INTS.buttonW, 
            ExtConstants.UI.INTS.buttonH 
        },
        isVisible = function() return utils.Settings["showLevelCap"] end,
        getText = function() 
            if LevelcapHandler.highestBadge == 8 then
                return "Levelcap: " .. ExtConstants.LEVEL_CAP_BY_TRAINER_IDS_FRLG[LevelcapHandler.highestTrainer] 
            end
            return "Levelcap: " .. ExtConstants.LEVEL_CAP_BY_BADGES[LevelcapHandler.highestBadge] 
        end,
    },
    RouteLinkedAlready = {
        type = Constants.ButtonTypes.ICON_BORDER,
        image = Constants.PixelImages.WARNING,
        iconColors = { 0xFFF04037, 0xFFFF0000, 0xFFFFFFFF },
        box = { 
            0, 
            Constants.SCREEN.HEIGHT + bottomAreaPadding + ExtConstants.UI.INTS.buttonH + 6, 
            ExtConstants.UI.INTS.buttonW + 28, 
            ExtConstants.UI.INTS.buttonH 
        },
        getText = function() 
            if LinkHandler:RouteIdBannedAlready(TrackerAPI.getMapId()) == true then
                return "Route is banned"
            else
                return "Route already linked" 
            end
        end,
        isVisible = function() 
            if utils.Settings["showLinkWarning"] == false then return false end

            local alreadyLinked = LinkHandler:idAlreadyLinked(TrackerAPI.getMapId()) == true
            local banned = LinkHandler:RouteIdBannedAlready(TrackerAPI.getMapId()) == true

            return banned or alreadyLinked
        end,
        onClick = function() end,
    },
    PokemonLinkedAlready = {
        type = Constants.ButtonTypes.ICON_BORDER,
        image = Constants.PixelImages.WARNING,
        iconColors = { 0xFFF04037, 0xFFFF0000, 0xFFFFFFFF },
        box = { 
            ExtConstants.UI.INTS.buttonW + 31, 
            Constants.SCREEN.HEIGHT + bottomAreaPadding + ExtConstants.UI.INTS.buttonH + 6, 
            ExtConstants.UI.INTS.buttonW + 42, 
            ExtConstants.UI.INTS.buttonH 
        },
        getText = function() 
            if LinkHandler:PokemonIdBannedAlready(MainButtonsScreen.enemyPokemon.pokemonID) == true then
                return "Pokemon is banned" 
            else
                return "Pokemon already linked" 
            end
            
        end,
        isVisible = function() 
            if utils.Settings["showLinkWarning"] == false then return false end

            if not MainButtonsScreen.enemyPokemon then return false end

            local alreadyLinked = LinkHandler:idAlreadyLinked(MainButtonsScreen.enemyPokemon.pokemonID)
            local banned = LinkHandler:PokemonIdBannedAlready(MainButtonsScreen.enemyPokemon.pokemonID)

            return banned or alreadyLinked
        end,
        onClick = function() end,
    },
}

-- DRAWING FUNCTIONS
function MainButtonsScreen.drawScreen()
    for _, button in pairs(MainButtonsScreen.Buttons) do
        Drawing.drawButton(button)
    end
end

-- USER INPUT FUNCTIONS
function MainButtonsScreen.checkInput(xmouse, ymouse)
    Input.checkButtonsClicked(xmouse, ymouse, MainButtonsScreen.Buttons)
end

function MainButtonsScreen.afterBattleBegins()
    if Battle.isWildEncounter == true then
        MainButtonsScreen.enemyPokemon = TrackerAPI.getEnemyPokemon()
    end
end

function MainButtonsScreen.afterBattleEnds()
    MainButtonsScreen.enemyPokemon = nil
end

return MainButtonsScreen