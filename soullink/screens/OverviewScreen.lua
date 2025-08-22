OverviewScreen = {
	Key = "Overview",
    Description = "Overview"
}

OverviewScreen.Buttons = {
	Close = {
        type = Constants.ButtonTypes.PIXELIMAGE,
        image = Constants.PixelImages.CLOSE,
        iconColors = { ExtConstants.UI.COLORS.text },
        box = { Constants.SCREEN.WIDTH - 13, ExtConstants.UI.INTS.gap, 10, 10 },
        onClick = function() ScreenHandler:toggleScreen(OverviewScreen.Key) end,
    },
    CurrentPage = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function() return OverviewScreen.Pager:getPageText() end,
		box = { 100, Constants.SCREEN.HEIGHT - 20, 50, 10, },
		isVisible = function() return OverviewScreen.Pager.totalPages > 1 end,
	},
	PrevPage = {
		type = Constants.ButtonTypes.ICON_BORDER,
        image = Constants.PixelImages.LEFT_ARROW,
        iconColors = { ExtConstants.UI.COLORS.text },
        box = { 
            5, 
            Constants.SCREEN.HEIGHT - ExtConstants.UI.INTS.buttonH - ExtConstants.UI.INTS.gap, 
            ExtConstants.UI.INTS.buttonW, 
            ExtConstants.UI.INTS.buttonH 
        },
		getText = function() return "Previous" end,
		isVisible = function() return OverviewScreen.Pager.totalPages > 1 end,
		onClick = function() OverviewScreen.Pager:prevPage() end
	},
	NextPage = {
		type = Constants.ButtonTypes.ICON_BORDER,
        image = Constants.PixelImages.RIGHT_ARROW,
        iconColors = { ExtConstants.UI.COLORS.text },
        box = { 
            Constants.SCREEN.WIDTH - ExtConstants.UI.INTS.buttonW - 5, 
            Constants.SCREEN.HEIGHT - ExtConstants.UI.INTS.buttonH - ExtConstants.UI.INTS.gap, 
            ExtConstants.UI.INTS.buttonW, 
            ExtConstants.UI.INTS.buttonH 
        },
		getText = function() return "Next" end,
		isVisible = function() return OverviewScreen.Pager.totalPages > 1 end,
		onClick = function() OverviewScreen.Pager:nextPage() end
	},
}

OverviewScreen.Pager = {
	LinkBoxes = {},
	currentPage = 0,
	totalPages = 0,
	realignButtonsToGrid = function(this)
		local x, y = ExtConstants.UI.INTS.gap, 20
		local colSpacer = ExtConstants.UI.INTS.gap
		local rowSpacer = ExtConstants.UI.INTS.gap
		local maxWidth = Constants.SCREEN.WIDTH - ExtConstants.UI.INTS.gap
		local maxHeight = Constants.SCREEN.HEIGHT - ExtConstants.UI.INTS.gap

		local totalPages = Utils.gridAlign(this.LinkBoxes, x, y, colSpacer, rowSpacer, false, maxWidth, maxHeight)
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
function OverviewScreen.drawScreen()
	if not ScreenHandler:isDisplayed(OverviewScreen.Key) then return end

	local links = LinkHandler:getLinks() or {}
    local linkLength = #links

    Drawing.drawBackgroundAndMargins(0, 0, Constants.SCREEN.WIDTH, Constants.SCREEN.HEIGHT, ExtConstants.UI.COLORS.background)

	-- Header
    Drawing.drawText(ExtConstants.UI.INTS.gap, 5, "Linked Pokémon", ExtConstants.UI.COLORS.text)

	if linkLength == 0 then
		Drawing.drawText(ExtConstants.UI.INTS.gap, 20, "(No Pokémon linked)", ExtConstants.UI.COLORS.text)
	end

    -- Draw each of the LinkBoxes
	for _, button in pairs(OverviewScreen.Pager.LinkBoxes) do
		Drawing.drawButton(button)
	end

    -- Draw all other buttons
	for _, button in pairs(OverviewScreen.Buttons) do
		Drawing.drawButton(button)
	end
end

-- USER INPUT FUNCTIONS
function OverviewScreen.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, OverviewScreen.Buttons)
	Input.checkButtonsClicked(xmouse, ymouse, OverviewScreen.Pager.LinkBoxes)

	-- check input on linkbox buttons
	for _, linkBox in ipairs(OverviewScreen.Pager.LinkBoxes) do
		if linkBox.Buttons ~= nil then
			if linkBox.updateChildPositions then linkBox:updateChildPositions() end
			Input.checkButtonsClicked(xmouse, ymouse, linkBox.Buttons)
		end
	end
end

function OverviewScreen:buildPagedButtons()
	self.Pager.LinkBoxes = {}
	local links = LinkHandler:getLinks() or {}

    for _, link in pairs(links) do
		local leftData = DataHelper.buildPokemonInfoDisplay(link.pokemon1Id)
		local rightData = DataHelper.buildPokemonInfoDisplay(link.pokemon2Id)
		local routeId = link.routeId
		local routeName = RouteData.Info[routeId].name

		local left = leftData.p
		local right = rightData.p

        local box = {
			Buttons = { 
				leftPokemonBtn = nil, 
				rightPokemonBtn = nil, 
				arrowBtn = nil,
				deleteBtn = nil
			},
            type = Constants.ButtonTypes.FULL_BORDER,
            dimensions = { width = 115, height = 50, },
			isVisible = function(this) return self.Pager.currentPage == this.pageVisible end,
			getPos = function(this)
				local bx = (this.box and this.box[1]) or 0
				local by = (this.box and this.box[2]) or 0
				local bw = (this.dimensions and this.dimensions.width)  or 0
				local bh = (this.dimensions and this.dimensions.height) or 0
				return bx, by, bw, bh
			end,
			updateChildPositions = function(this)
				local bx, by, maxX, maxY = this:getPos()

				this.Buttons.leftPokemonBtn.box[1] = bx + 5   	-- x
				this.Buttons.leftPokemonBtn.box[2] = by + 5   	-- y

				this.Buttons.rightPokemonBtn.box[1] = bx + 69   -- x
				this.Buttons.rightPokemonBtn.box[2] = by + 5   	-- y

				this.Buttons.arrowBtn.box[1] = bx + 47  		-- x
				this.Buttons.arrowBtn.box[2] = by + 20   		-- y

				this.Buttons.deleteBtn.box[1] = bx + maxX - 13 	-- x
				this.Buttons.deleteBtn.box[2] = by + maxY - 13  -- y
			end,
			draw = function(this)
				if not this:isVisible() then return end
				local bx, by, maxX, maxY = this:getPos()

				this:updateChildPositions()

				-- pokemon name
				Drawing.drawText(bx + 3, by + 1, left.name)
				Drawing.drawText(bx + 69, by + 1, right.name)

				-- route name
            	Drawing.drawText(bx + 1, by + maxY - 11, string.format("@ %s", routeName))

				-- Draw all the clickable buttons
				for _, button in pairs(this.Buttons) do
					Drawing.drawButton(button)
				end
			end
        }

		-- left pokemon
		local iconBtn = {
			type = Constants.ButtonTypes.POKEMON_ICON,
			getIconId = function() return left.id, SpriteData.Types.Idle end,
			box = { 0, 0, 32, 32 },
			onClick = function()
				if PokemonData.isValid(left.id) then
					InfoScreen.changeScreenView(InfoScreen.Screens.POKEMON_INFO, left.id)
				end
			end
		}
		box.Buttons.leftPokemonBtn = iconBtn

		-- right pokemon
		iconBtn = {
			type = Constants.ButtonTypes.POKEMON_ICON,
			getIconId = function() return right.id, SpriteData.Types.Idle end,
			box = {0, 0, 32, 32 },
			onClick = function()
				if PokemonData.isValid(right.id) then
					InfoScreen.changeScreenView(InfoScreen.Screens.POKEMON_INFO, right.id)
				end
			end
		}
		box.Buttons.rightPokemonBtn = iconBtn

		-- arrow
		local arrow = {
			type = Constants.ButtonTypes.PIXELIMAGE,
			image = Constants.PixelImages.RIGHT_ARROW,
			iconColors = { ExtConstants.UI.COLORS.text },
			box = { 0, 0, 10, 10 },
		}
		box.Buttons.arrowBtn = arrow

		-- pokemon dead
		local delete = {
			type = Constants.ButtonTypes.PIXELIMAGE,
			image = Constants.PixelImages.CLOSE,
			iconColors = { 0xFFF04037, 0xFFFF0000, 0xFFFFFFFF },
			box = { 0, 0, 10, 10 },
			onClick = function(self)
				LinkHandler.promptDeleteLinkByRoute(routeId)
			end
		}
		box.Buttons.deleteBtn = delete

        table.insert(self.Pager.LinkBoxes, box)
    end


	self.Pager:realignButtonsToGrid()

	return true
end

return OverviewScreen