BanlistScreen = {
    Key = "Banlist",
    Description = "Banlist",
    showRoutes = false
}

BanlistScreen.Buttons = {
    Close = {
        type = Constants.ButtonTypes.PIXELIMAGE,
        image = Constants.PixelImages.CLOSE,
        iconColors = { ExtConstants.UI.COLORS.text },
        box = { 
            Constants.SCREEN.WIDTH - 11, 
            2, 
            10, 
            10 
        },
        onClick = function() ScreenHandler:toggleScreen(BanlistScreen.Key) end,
    },
    BanPokemon = {
        type = Constants.ButtonTypes.ICON_BORDER,
        image = Constants.PixelImages.CLOSE,
        iconColors = { 0xFFF04037, 0xFFFF0000, 0xFFFFFFFF },
        box = { 
            ExtConstants.UI.INTS.gap, 
            20, 
            ExtConstants.UI.INTS.buttonW, 
            ExtConstants.UI.INTS.buttonH 
        },
        isVisible = function() return true end,
        getText = function() return "Ban Pokémon" end,
        onClick = function() 
            utils.createChoosePokemonForm(
                function(data)
                    LinkHandler:banPokemon(data.p)
                end
            )
        end,
    },
    BanRoute = {
        type = Constants.ButtonTypes.ICON_BORDER,
        image = Constants.PixelImages.CLOSE,
        iconColors = { 0xFFF04037, 0xFFFF0000, 0xFFFFFFFF },
        box = { 
            ExtConstants.UI.INTS.buttonW + 6,
            20, 
            ExtConstants.UI.INTS.buttonW, 
            ExtConstants.UI.INTS.buttonH 
        },
        isVisible = function() return true end,
        getText = function() return "Ban Route" end,
        onClick = function() 
            utils.createChooseRouteForm(
                function(routeId)
                    LinkHandler:banRouteId(routeId)
                end
            )
        end,
    },
    ShowRoutes = {
        type = Constants.ButtonTypes.CHECKBOX,
        settingKey = settingKey,
        textColor = "Default text",
        box = { ExtConstants.UI.INTS.buttonW * 2 + 14, 24, 8, 8 },
        boxColors = { "Upper box border", "Upper box background" },
        toggleState = showRoutes,
        isVisible = function() return true end,
        getText = function() return "Show Routes" end,
        onClick = function(this)
            BanlistScreen.showRoutes = not BanlistScreen.showRoutes

            -- reset page
            BanlistScreen.Pager.currentPage = 1 

            this.toggleState = BanlistScreen.showRoutes
            BanlistScreen:buildPagedButtons()
            Program.redraw(true)
        end
    },
    CurrentPage = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function() return BanlistScreen.Pager:getPageText() end,
		box = { 100, Constants.SCREEN.HEIGHT - 20, 50, 10, },
		isVisible = function() return BanlistScreen.Pager.totalPages > 1 end,
	},
    Prev = {
        type = Constants.ButtonTypes.ICON_BORDER,
        image = Constants.PixelImages.LEFT_ARROW,
        iconColors = { ExtConstants.UI.COLORS.text },
        box = {
            ExtConstants.UI.INTS.gap,
            Constants.SCREEN.HEIGHT - ExtConstants.UI.INTS.buttonH - ExtConstants.UI.INTS.gap,
            ExtConstants.UI.INTS.buttonW,
            ExtConstants.UI.INTS.buttonH
        },
        isVisible = function() return BanlistScreen.Pager.totalPages > 1 end,
        getText = function() return "Previous" end,
        onClick = function() BanlistScreen.Pager:prevPage() end,
    },
    Next = {
        type = Constants.ButtonTypes.ICON_BORDER,
        image = Constants.PixelImages.RIGHT_ARROW,
        iconColors = { ExtConstants.UI.COLORS.text },
        box = {
            Constants.SCREEN.WIDTH - ExtConstants.UI.INTS.buttonW - ExtConstants.UI.INTS.gap,
            Constants.SCREEN.HEIGHT - ExtConstants.UI.INTS.buttonH - ExtConstants.UI.INTS.gap,
            ExtConstants.UI.INTS.buttonW,
            ExtConstants.UI.INTS.buttonH
        },
        isVisible = function() return BanlistScreen.Pager.totalPages > 1 end,
        getText = function() return "Next" end,
        onClick = function() BanlistScreen.Pager:nextPage() end,
    }
}

BanlistScreen.Pager = {
	BanBoxes = {},
	currentPage = 0,
	totalPages = 0,
	realignButtonsToGrid = function(this)
		local x, y = ExtConstants.UI.INTS.gap, 40
		local colSpacer = ExtConstants.UI.INTS.gap
		local rowSpacer = ExtConstants.UI.INTS.gap
		local maxWidth = Constants.SCREEN.WIDTH - ExtConstants.UI.INTS.gap
		local maxHeight = Constants.SCREEN.HEIGHT - ExtConstants.UI.INTS.gap

		local totalPages = Utils.gridAlign(this.BanBoxes, x, y, colSpacer, rowSpacer, false, maxWidth, maxHeight)
		this.currentPage = 1
		this.totalPages = totalPages or 1
	end,
	getPageText = function(this)
		if this.totalPages <= 1 then return Resources.AllScreens.Page end
		return string.format("%s %s/%s", Resources.AllScreens.Page, this.currentPage, this.totalPages)
	end,
	prevPage = function(this)
		if this.totalPages <= 1 then return end
		this.currentPage = ((this.currentPage - 2 + this.totalPages) % this.totalPages) + 1
		Program.redraw(true)
	end,
	nextPage = function(this)
		if this.totalPages <= 1 then return end
		this.currentPage = (this.currentPage % this.totalPages) + 1
		Program.redraw(true)
	end,
}

-- DRAWING FUNCTIONS
function BanlistScreen.drawScreen()
    if not ScreenHandler:isDisplayed(BanlistScreen.Key) then return end

    Drawing.drawBackgroundAndMargins(0, 0, Constants.SCREEN.WIDTH, Constants.SCREEN.HEIGHT, ExtConstants.UI.COLORS.background)
    Drawing.drawText(ExtConstants.UI.INTS.gap, 5, "Banlist", ExtConstants.UI.COLORS.text)

    -- Draw each of the BanBoxes
	for _, button in pairs(BanlistScreen.Pager.BanBoxes) do
		Drawing.drawButton(button)
	end

    -- Draw all other buttons
    for _, button in pairs(BanlistScreen.Buttons) do
        Drawing.drawButton(button)
    end
end


-- USER INPUT FUNCTIONS
function BanlistScreen.checkInput(xmouse, ymouse)
    Input.checkButtonsClicked(xmouse, ymouse, BanlistScreen.Buttons)
    Input.checkButtonsClicked(xmouse, ymouse, BanlistScreen.Pager.BanBoxes)

    -- check input on banbox buttons
    for _, banBox in ipairs(BanlistScreen.Pager.BanBoxes) do
		if banBox.Buttons ~= nil then
            if banBox.updateChildPositions then banBox:updateChildPositions() end
			Input.checkButtonsClicked(xmouse, ymouse, banBox.Buttons)
		end
	end
end

function BanlistScreen:buildPagedButtons()
    self.Pager.BanBoxes = {}

    if not self.showRoutes then
        for _, id in pairs(LinkHandler:getBannedPokemon() or {}) do
            self.createPokemonBanBox(id)
        end
    else
        for _, id in pairs(LinkHandler:getBannedRoutes() or {}) do
            self.createRouteBanBox(id)
        end
    end

    self.Pager:realignButtonsToGrid()
end

-- TODO updateself on theme change
function BanlistScreen.createPokemonBanBox(id)
    local pokemon = DataHelper.buildPokemonInfoDisplay(id).p
    if not pokemon then return end

    local banBox = {
        Buttons = { pokemonBtn = nil },
        type = Constants.ButtonTypes.FULL_BORDER,
        dimensions = { width = 56, height = 45, },
		isVisible = function(this) return BanlistScreen.Pager.currentPage == this.pageVisible end,
		getPos = function(this)
            local bx = (this.box and this.box[1]) or 0
            local by = (this.box and this.box[2]) or 0
            local bw = (this.dimensions and this.dimensions.width)  or 0
            local bh = (this.dimensions and this.dimensions.height) or 0
            return bx, by, bw, bh
        end,
        updateChildPositions = function(this)
            local bx, by, maxX, maxY = this:getPos()

            this.Buttons.pokemonBtn.box[1] = bx + 12   	-- x
            this.Buttons.pokemonBtn.box[2] = by + 5   	-- y
        end,
        draw = function(this)
            if not this:isVisible() then return end
            local bx, by, maxX, maxY = this:getPos()
            this:updateChildPositions()

            -- pokemon name
            Drawing.drawText(bx + 3, by + 1, pokemon.name)

            -- Draw all the clickable buttons
            for _, button in pairs(this.Buttons) do
                Drawing.drawButton(button)
            end
        end
	}

    -- pokemon
    local iconBtn = {
        type = Constants.ButtonTypes.POKEMON_ICON,
        getIconId = function() return pokemon.id, SpriteData.Types.Idle end,
        box = { 0, 0, 32, 32 },
        onClick = function()
            if PokemonData.isValid(pokemon.id) then
                InfoScreen.changeScreenView(InfoScreen.Screens.POKEMON_INFO, pokemon.id)
            end
        end
    }
    banBox.Buttons.pokemonBtn = iconBtn

    table.insert(BanlistScreen.Pager.BanBoxes, banBox)

    return true
end

function BanlistScreen.createRouteBanBox(id)
    local routeId = id
    local routeName = RouteData.Info[routeId].name

    if not routeId then return end

    local banBox = {
		Buttons = { showRouteBtn = nil },
        type = Constants.ButtonTypes.FULL_BORDER,
        dimensions = { width = 76, height = 20, },
		isVisible = function(this) return BanlistScreen.Pager.currentPage == this.pageVisible end,
        getPos = function(this)
            local bx = (this.box and this.box[1]) or 0
            local by = (this.box and this.box[2]) or 0
            local bw = (this.dimensions and this.dimensions.width)  or 0
            local bh = (this.dimensions and this.dimensions.height) or 0
            return bx, by, bw, bh
        end,
        updateChildPositions = function(this)
            local bx, by, maxX, maxY = this:getPos()

            this.Buttons.showRouteBtn.box[1] = bx + 3   	            -- x
            this.Buttons.showRouteBtn.box[2] = by + 5   	            -- y

            this.Buttons.showRouteBtn.clickableArea[1] = bx   	        -- x
            this.Buttons.showRouteBtn.clickableArea[2] = by   	        -- y
            this.Buttons.showRouteBtn.clickableArea[3] = maxX   	    -- width
            this.Buttons.showRouteBtn.clickableArea[4] = maxY   	    -- heigth
        end,
		draw = function(this)
            if not this:isVisible() then return end
			local bx, by, maxX, maxY = this:getPos()
            this:updateChildPositions()

			-- Route name
			Drawing.drawText(bx + 17, by + 4, routeName)

            -- Draw all the clickable buttons
			for _, button in pairs(this.Buttons) do
				Drawing.drawButton(button)
			end
		end,
	}

    -- show route button
	local iconBtn = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.MAGNIFYING_GLASS,
        clickableArea = { 0, 0, 0, 0 },
		box = { 0, 0, 10, 10 },
		onClick = function()
            -- get first encounterArea of route and open info
            local encounterArea
            for _, area in pairs(RouteData.OrderedEncounters) do
                encounterArea = RouteData.Info[routeId][area]

                if encounterArea then
                    break
                end
            end

            if encounterArea == nil then return end

            local routeInfo = {
                mapId = routeId,
                encounterArea = encounterArea,
            }
            InfoScreen.changeScreenView(InfoScreen.Screens.ROUTE_INFO, routeInfo)
		end
	}
    banBox.Buttons.showRouteBtn = iconBtn

    table.insert(BanlistScreen.Pager.BanBoxes, banBox)
    
    return true
end

return BanlistScreen