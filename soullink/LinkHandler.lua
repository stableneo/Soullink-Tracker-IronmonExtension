LinkHandler = {
	pokemon1 = nil,
	pokemon2 = nil,
	currentRouteId = nil,
	links = {},
    remainingRoutes = {},
    remainingPokemon = {},
    bannedPokemon = {},
    bannedRoutes = {}
}

-- links pokemon and saves it to json
function LinkHandler:linkPokemon()
    if self:linkReady() == false then return end

    local pokemon1 = self.pokemon1
    local pokemon2 = self.pokemon2
    local routeId = self.currentRouteId

    local link = {
        pokemon1Id  	= pokemon1.id,
        pokemon2Id 	    = pokemon2.id,
        pokemon1Name 	= pokemon1.name,
        pokemon2Name 	= pokemon2.name,
        routeId 	    = routeId,
    }

    table.insert(self.links, link)
    if ExtConstants.DEBUG then 
        print(string.format("Linked %s ↔ %s @ %s", link.pokemon1Name, link.pokemon2Name, link.routeId))
    end

    -- only save pokemon once if the same are linked
    if pokemon1.id ~= pokemon2.id then
        self:banPokemon(pokemon1)
        self:banPokemon(pokemon2)
    else
        self:banPokemon(pokemon1)
    end
    
    self:banRouteId(routeId)

    utils.saveJson()

    self.pokemon1 = nil
    self.pokemon2 = nil
    self.currentRouteId = nil
end

-- ban pokemon functions
function LinkHandler:banPokemon(pokemon)
    if not pokemon then return end
    if self:PokemonIdBannedAlready(pokemon.id) then return end

    table.insert(self.bannedPokemon, pokemon.id)
    if ExtConstants.DEBUG then print(string.format("banned %s!", pokemon.name)) end

    utils.saveJson()
end

function LinkHandler:PokemonIdBannedAlready(pokemonId)
    if not pokemonId then return false end

    -- dont add pokemon if already banned
    for _, id in ipairs(self.bannedPokemon) do
        if pokemonId == id then
            return true
        end
    end

    return false
end


-- ban route functions
function LinkHandler:banRouteId(routeId)
    if not routeId then return end
    if self:RouteIdBannedAlready(routeId) then return end

    table.insert(self.bannedRoutes, routeId)
    if ExtConstants.DEBUG then print(string.format("banned %s!", RouteData.Info[routeId].name)) end

    utils.saveJson()
end

function LinkHandler:RouteIdBannedAlready(routeId)
    -- dont add route if already banned
    for _, id in pairs(self.bannedRoutes) do
        if routeId == id then
            return true
        end
    end

    return false
end

-- Getter/Setter
-- links
function LinkHandler:setLinks(newLinks)
    self.links = newLinks or {}
end

function LinkHandler:getLinks()
    return self.links
end

-- banned pokemon
function LinkHandler:setBannedPokemon(newData)
    self.bannedPokemon = newData or {}
end

function LinkHandler:getBannedPokemon()
    return self.bannedPokemon
end

-- banned routes 
function LinkHandler:setBannedRoutes(newData)
    self.bannedRoutes = newData or {}
end

function LinkHandler:getBannedRoutes()
    return self.bannedRoutes
end

-- pokemon1
function LinkHandler:setPokemon1(pokemonData)
    if not pokemonData then return end
    self.pokemon1 = pokemonData
end

function LinkHandler:getPokemon1()
    return self.pokemon1
end

function LinkHandler:getPokemon1NameLabel()
    return (self.pokemon1 and self.pokemon1.name) or "choose Link"
end

-- pokemon2
function LinkHandler:setPokemon2(pokemonData)
    if not pokemonData then return end
    self.pokemon2 = pokemonData
end

function LinkHandler:getPokemon2()
    return self.pokemon2
end

function LinkHandler:getPokemon2NameLabel()
    return (self.pokemon2 and self.pokemon2.name) or "choose Link"
end


-- Route functions
function LinkHandler.updateRouteIdFromPlayerPosition()
    local routeId = TrackerAPI.getMapId()
    if routeId and not LinkHandler:idAlreadyLinked(routeId) then
        LinkHandler.setRouteId(routeId)
    end
end

function LinkHandler.setRouteId(newRouteId)
    if not newRouteId then return end

    LinkHandler.currentRouteId = newRouteId
end

function LinkHandler.getRouteId()
    return (LinkHandler.currentRouteId)
end

function LinkHandler.getRouteNameLabel()
    return (LinkHandler.currentRouteId and RouteData.Info[LinkHandler.currentRouteId].name) or "choose Route"
end


-- Util functions
function LinkHandler:clearAll()
    self.pokemon1 = nil
    self.pokemon2 = nil
    self.currentRouteId = nil
end

-- deprecated
-- function LinkHandler.bothPokemonSelected()
--     return (LinkHandler.pokemon1 and LinkHandler.pokemon2)
-- end

function LinkHandler:linkReady()
    return (self.pokemon1 ~= nil) and
            (self.pokemon2 ~= nil) and
            (self.currentRouteId ~= nil)
end

function LinkHandler:idAlreadyLinked(id)
    if not id then return false end

    for _, l in ipairs(self.links) do
        if l.routeId == id then
            return true
        elseif l.rightId == id then
            return true
        elseif l.leftId == id then
            return true
        end
    end

    return false
end

function LinkHandler:getAllUsedRouteNames()
    local result = {}

    for _, l in ipairs(self.links) do
        local route = RouteData.Info[l.routeId]
        if route and route.name then
            table.insert(result, Utils.formatSpecialCharacters(route.name))
        end
    end

    if #self.bannedRoutes == 0 then return result end
    for _, routeId in pairs(self.bannedRoutes) do
        local route = RouteData.Info[routeId]
        if route and route.name then
            table.insert(result, Utils.formatSpecialCharacters(route.name))
        end
    end

    return result
end

function LinkHandler:checkAndUpdateAvailableRoutes()
    -- filter already linked routes out
    local alreadyLinkedRoutes = self:getAllUsedRouteNames() or {}
    local availableRoutes = RouteData.AvailableRoutes or {}

    local linkedSet = {}
    for _, name in ipairs(alreadyLinkedRoutes) do
        linkedSet[name] = true
    end

    local remainingRoutes = {}
    for _, name in ipairs(availableRoutes) do
        if not linkedSet[name] then
            table.insert(remainingRoutes, name)
        end
    end

    self.remainingRoutes = remainingRoutes
end

function LinkHandler:getAllLinkedPokemonNames()
    local result = {}

    for _, l in ipairs(self.links) do
        table.insert(result, l.pokemon1Name)
        table.insert(result, l.pokemon2Name)
    end

    if #self.bannedPokemon == 0 then return result end
    for _, pokemonId in pairs(self.bannedPokemon) do
        local p = DataHelper.buildPokemonInfoDisplay(pokemonId).p
        if p then
            table.insert(result, p.name)
        end
    end

    return result
end

function LinkHandler:checkAndUpdateAvailablePokemon()
    -- filter already linked routes out
    local alreadyLinkedPokemon = self:getAllLinkedPokemonNames()
    local availablePokemon = PokemonData.namesToList()

    local linkedSet = {}
    for _, name in ipairs(alreadyLinkedPokemon) do
        linkedSet[name] = true
    end

    local remainingPokemon = {}
    for _, name in ipairs(availablePokemon) do
        if not linkedSet[name] then
            table.insert(remainingPokemon, name)
        end
    end

    self.remainingPokemon = remainingPokemon
end

function LinkHandler.promptDeleteLinkByRoute(routeId)
    local formWidth, formHeight = 360, 105
    local btnW, btnH = 100, 30

    local form = ExternalUI.BizForms.createForm("Delete Link", formWidth, formHeight)
    form:createLabel("Do you really want to delete this link?", 49, 10)

    -- calculate spacing
    local spacing = (formWidth - (2 * btnW)) / 3
    local y = formHeight - btnH - 10

    local x1 = spacing
    local x2 = spacing * 2 + btnW

    form:createButton("Yes", x1, y, function()
        utils.deleteLinkByRouteId(routeId)
        OverviewScreen:buildPagedButtons()
        form:destroy()
    end, btnW, btnH)

    form:createButton("No", x2, y, function()
        form:destroy()
    end, btnW, btnH)
end

function LinkHandler.promptDeleteLinkByPokemon(pokemonId)
    local formWidth, formHeight = 360, 105
    local btnW, btnH = 100, 30

    local form = ExternalUI.BizForms.createForm("Delete Link", formWidth, formHeight)
    form:createLabel("Do you really want to delete this link?", 49, 10)

    -- calculate spacing
    local spacing = (formWidth - (2 * btnW)) / 3
    local y = formHeight - btnH - 10

    local x1 = spacing
    local x2 = spacing * 2 + btnW

    form:createButton("Yes", x1, y, function()
        utils.deleteLinkByPokemonId(pokemonId)
        OverviewScreen:buildPagedButtons()
        form:destroy()
    end, btnW, btnH)

    form:createButton("No", x2, y, function()
        form:destroy()
    end, btnW, btnH)

    
end

return LinkHandler