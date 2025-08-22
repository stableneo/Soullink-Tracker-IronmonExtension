LinkScreen = {
    Key = "Link",
    Description = "Create Link",
    linkY = 50
}

LinkScreen.Buttons = {
    Close = {
        type = Constants.ButtonTypes.PIXELIMAGE,
        image = Constants.PixelImages.CLOSE,
        iconColors = { ExtConstants.UI.COLORS.text },
        box = { Constants.SCREEN.WIDTH - 13, ExtConstants.UI.INTS.gap, 10, 10 },
        onClick = function(this) ScreenHandler:toggleScreen(LinkScreen.Key) end,
    },
    ChooseLeftPokemon = {
        name = "leftPokemon",
        type = Constants.ButtonTypes.ICON_BORDER,
        image = Constants.PixelImages.POKEBALL,
        iconColors = TrackerScreen.PokeBalls.ColorList,
        box = { 
            ExtConstants.UI.INTS.gap,
            Constants.SCREEN.HEIGHT - ExtConstants.UI.INTS.buttonH - ExtConstants.UI.INTS.gap, 
            ExtConstants.UI.INTS.buttonW, 
            ExtConstants.UI.INTS.buttonH 
        },
        getText = function() return LinkHandler:getPokemon1NameLabel() end,
        onClick = function() 
            utils.createChoosePokemonForm(
                function(data)
                    LinkHandler:setPokemon1(data.p)
                end
            ) 
        end,
    },
    LeftPokemonBox = {
        pokemonId = nil,
        type = Constants.ButtonTypes.FULL_BORDER,
        box = { Constants.SCREEN.WIDTH / 2 - 50, LinkScreen.linkY, 32, 32 },
        draw = function(this) 
            this.pokemonId = LinkHandler:getPokemon1() and LinkHandler:getPokemon1().id
            if this.pokemonId then
                Drawing.drawPokemonIcon(this.pokemonId, this.box[1], this.box[2])
            end
        end
    },
    ChooseRightPokemon = {
        name = "rightPokemon",
        type = Constants.ButtonTypes.ICON_BORDER,
        image = Constants.PixelImages.POKEBALL,
        iconColors = TrackerScreen.PokeBalls.ColorList,
        box = { 
            3 + Constants.SCREEN.WIDTH / 3,
            Constants.SCREEN.HEIGHT - ExtConstants.UI.INTS.buttonH - ExtConstants.UI.INTS.gap, 
            ExtConstants.UI.INTS.buttonW, 
            ExtConstants.UI.INTS.buttonH 
        },
        getText = function() return LinkHandler:getPokemon2NameLabel() end,
        onClick = function() 
            utils.createChoosePokemonForm(
                function(data)
                    LinkHandler:setPokemon2(data.p)
                end
            ) 
        end,
    },
    RightPokemonBox = {
        pokemonId = nil,
        type = Constants.ButtonTypes.FULL_BORDER,
        box = { Constants.SCREEN.WIDTH / 2 + 50 - 32, LinkScreen.linkY, 32, 32 },
        draw = function(this) 
            this.pokemonId = LinkHandler:getPokemon2() and LinkHandler:getPokemon2().id
            if this.pokemonId then
                Drawing.drawPokemonIcon(this.pokemonId, this.box[1], this.box[2])
            end
        end
    },
    ChooseRoute = {
        type = Constants.ButtonTypes.ICON_BORDER,
        image = Constants.PixelImages.MAGNIFYING_GLASS,
        box = { 
            Constants.SCREEN.WIDTH - ExtConstants.UI.INTS.buttonW - ExtConstants.UI.INTS.gap,
            Constants.SCREEN.HEIGHT - ExtConstants.UI.INTS.buttonH - ExtConstants.UI.INTS.gap, 
            ExtConstants.UI.INTS.buttonW, 
            ExtConstants.UI.INTS.buttonH 
        },
        getText = function() 
            if LinkHandler:RouteIdBannedAlready(TrackerAPI.getMapId()) == true then
                return "choose Route"
            else
                return LinkHandler.getRouteNameLabel() 
            end
        end,
        onClick = function() 
            utils.createChooseRouteForm(
                function(routeId)
                    LinkHandler.setRouteId(routeId)
                end
            ) 
        end,
    },
    Arrow = {
        type = Constants.ButtonTypes.PIXELIMAGE,
        image = Constants.PixelImages.RIGHT_ARROW,
        iconColors = { ExtConstants.UI.COLORS.text },
        box = { Constants.SCREEN.WIDTH / 2 - 5, LinkScreen.linkY + 11, 10, 10 },
    },
    Link = {
        type = Constants.ButtonTypes.ICON_BORDER,
        image = Constants.PixelImages.HEART,
        iconColors = { ExtConstants.UI.COLORS.text },
        box = { 
            Constants.SCREEN.WIDTH - 40 - ExtConstants.UI.INTS.gap,
            LinkScreen.linkY + ExtConstants.UI.INTS.buttonH / 2,
            40, 
            ExtConstants.UI.INTS.buttonH
        },
        getText = function() return "Link" end,
        isVisible = function() return LinkHandler:linkReady() end,
        onClick = function() 
            LinkHandler:linkPokemon() 
            ScreenHandler:toggleScreen(LinkScreen.Key)
        end
    }
}

-- DRAWING FUNCTIONS
function LinkScreen.drawScreen()
    if not ScreenHandler:isDisplayed(LinkScreen.Key) then return end

    Drawing.drawBackgroundAndMargins(0, 0, Constants.SCREEN.WIDTH, Constants.SCREEN.HEIGHT, ExtConstants.UI.COLORS.background)
    Drawing.drawText(ExtConstants.UI.INTS.gap, 5, "Link Pokémon", ExtConstants.UI.COLORS.text)

    -- Draw all buttons
    for _, button in pairs(LinkScreen.Buttons) do
        Drawing.drawButton(button)
    end
end

-- USER INPUT FUNCTIONS
function LinkScreen.checkInput(xmouse, ymouse)
    Input.checkButtonsClicked(xmouse, ymouse, LinkScreen.Buttons)
end

return LinkScreen