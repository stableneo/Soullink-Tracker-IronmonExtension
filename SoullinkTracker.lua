local function SoullinkTracker()
	local self = {}
	self.version = "1.0"
	self.name = "Soullink Tracker"
	self.author = "Neo"
	self.description = "This is a tracker for a soullink challenge."
	self.github = "stableneo/Soullink-Tracker-IronmonExtension"
	self.url = string.format("https://github.com/%s", self.github or "")

	local soullinkPath = FileManager.getExtensionsFolderPath() .. "soullink" .. FileManager.slash

	-- load globally
	local ExtConstants = dofile(soullinkPath .. "ExtConstants.lua")
	ExtConstants:initializePaths(soullinkPath)

	local LinkHandler = dofile(soullinkPath .. "LinkHandler.lua")
	local ScreenHandler = dofile(soullinkPath .. "ScreenHandler.lua")
	local LevelcapHandler = dofile(soullinkPath .. "LevelcapHandler.lua")

	local utils = dofile(soullinkPath .. "utils.lua")

	-- Executed when the user clicks the "Options" button while viewing the extension details within the Tracker's UI
	function self.configureOptions()
		ScreenHandler:toggleScreen("Settings")
	end

	-- Executed when the user clicks the "Check for Updates" button while viewing the extension details within the Tracker's UI
	-- The existence of this function will allow the Tracker to automatically update & install your extension if an update is available
	-- Returns [true, downloadUrl] if an update is available (downloadUrl auto opens in browser for user); otherwise returns [false, downloadUrl]
	function self.checkForUpdates()
		-- Update the pattern below to match your version. You can check what this looks like by visiting the latest release url on your repo
		local versionResponsePattern = '"tag_name":%s+"%w+(%d+%.%d+)"' -- matches "1.0" in "tag_name": "v1.0"
		local versionCheckUrl = string.format("https://api.github.com/repos/%s/releases/latest", self.github or "")
		local downloadUrl = string.format("%s/releases/latest", self.url or "")
		local compareFunc = function(a, b) return a ~= b and not Utils.isNewerVersion(a, b) end -- if current version is *older* than online version
		local isUpdateAvailable = Utils.checkForVersionUpdate(versionCheckUrl, self.version, versionResponsePattern, compareFunc)
		return isUpdateAvailable, downloadUrl
	end

	-- Executed when the user clicks the "Check for Updates" or "Update All Extensions" button
	-- NOTE: Only add this function to your extension if you need to override how the update is performed.
	-- Defining this function is optional. The below code is the default code the Tracker uses for all extensions that have a `self.github` or `self.url` value defined.
	-- Returns [true] if the auto-update is successful; false otherwise
	function self.downloadAndInstallUpdate()
		-- Note: After the extension files are downloaded from Github and unzipped, you may have extra files in there that aren't needed for the extension to work
		-- Refer to the documentation in TrackerAPI to learn more about how to exclude these files/folders, as well as how to download from a specific release branch
		local extensionFilenameKey = "SoullinkTracker" -- REPLACE WITH FILENAME OF EXTENSION
		local success = TrackerAPI.updateExtension(extensionFilenameKey)
		return success
	end

	-- Executed only once: When the extension is enabled by the user, and/or when the Tracker first starts up, after it loads all other required files and code
	function self.startup()
		-- create saves folder if not already done
		if not FileManager.folderExists(ExtConstants.PATHS.saves) then
			FileManager.createFolder(ExtConstants.PATHS.saves)
		end

    	-- always get current rom name and corresponding save file
		utils.updateSaveFileName()

		-- load all files
		utils.loadJson()
		utils.loadSettings()

		-- add ui space if needed
		utils.updateUISpace()

		-- setup levelcap on start
		LevelcapHandler:updateLevelCap()

		SettingsScreen.initialize()
	end

	-- Executed only once: When the extension is disabled by the user, necessary to undo any customizations, if able
	function self.unload()
		utils.resetUISpace()
	end

	-- Executed once every 30 frames or after any redraw event is scheduled (i.e. most button presses)
	function self.afterRedraw()
		if TrackerAPI.hasGameStarted() then
			ScreenHandler:renderMainButtons()
		end
	end

	-- Input-Hook from infiniteFusion addon
	-- [Bizhawk only] Executed each frame (60 frames per second)
	local prevMouseInput = {}
	function self.inputCheckBizhawk()
		-- Newer Tracker prevents mouse clicks while form is open
		if not Main.IsOnBizhawk() or Input.allowMouse == false then
			return
		end

		local mouseInput = input.getmouse() -- lowercase 'input' pulls directly from Bizhawk API
		-- Check only if pressed when it wasn't pressed before
		if mouseInput["Left"] and not prevMouseInput["Left"] then
			local xmouse = mouseInput["X"]
			local ymouse = mouseInput["Y"] + Constants.SCREEN.UP_GAP

			ScreenHandler:hookInput("Main", xmouse, ymouse)
		end
		prevMouseInput = mouseInput
	end

	local prompted = {}

	-- Executed once every 30 frames, after any battle related data from game memory is read in
	function self.afterBattleDataUpdate()
		for i = 1, 6 do
			local p = TrackerAPI.getPlayerPokemon(i)
			if p and PokemonData.isValid(p.pokemonID) and p.curHP == 0 then
				local id = p.pokemonID
				if not prompted[id] then
					LinkHandler.promptDeleteLinkByPokemon(id)
					prompted[id] = true
				end
			end
		end
	end

	-- Executed after a new battle begins (wild or trainer), and only once per battle
	function self.afterBattleBegins()
		LinkHandler.updateRouteIdFromPlayerPosition()
		ScreenHandler:hookEvent(MainButtonsScreen.Key, "afterBattleBegins")
	end

	-- Executed after a battle ends, and only once per battle
	function self.afterBattleEnds()
		ScreenHandler:hookEvent(MainButtonsScreen.Key, "afterBattleEnds")

		local currentEnemyPokemon = TrackerAPI.getEnemyPokemon()
		local battleOutcome = TrackerAPI.getBattleOutcome()

		if battleOutcome == 7 then
			local data = DataHelper.buildPokemonInfoDisplay(currentEnemyPokemon.pokemonID)
			local pokemon = data.p
			LinkHandler.setLeftPokemon(pokemon)

			-- open LinkScreen on catch
			if LinkHandler:idAlreadyLinked(TrackerAPI.getMapId()) == false and
				LinkHandler:idAlreadyLinked(pokemon.id) == false then

				LinkScreen.State.isDisplayed = true
            	Program.openOverlayScreen(LinkScreen, true)
			end
		else
			LinkHandler:clearAll()
		end

		LevelcapHandler:updateLevelCap()

		-- reset link prompts
		prompted = {}
	end

	return self
end
return SoullinkTracker