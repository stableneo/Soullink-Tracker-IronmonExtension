-- TODO global gap int
ExtConstants = {
	DEBUG = false,
	PATHS = {
		soullink = "",		-- must be initialized
		screens = "",		-- must be initialized
		saves = ""			-- must be initialized
	},
    UI = {
		INTS = {
			gap = 3,
			buttonW = 75,
			buttonH = 16,
			soullinkSpace = 20,
			soullinkSpaceExtended = 40
		},
		COLORS = {
			text = Drawing.Colors.WHITE,
			highlight = 0xFFFFFF00, -- Yellow
			background = 0xEE000000, -- The first two characters after the '0x' are the opacity
			success = 0xFF00FF00, -- Green
			fail = 0xFFFF0000, -- Red
		},
    },
	LEVEL_CAP_BY_BADGES = {
        [0] = 14, 
        [1] = 21, 
        [2] = 24, 
        [3] = 29, 
        [4] = 43, 
        [5] = 43, 
        [6] = 47, 
        [7] = 50, 
        [8] = 56
    },
	LEVEL_CAP_BY_TRAINER_IDS_FRLG = {
		[410]	= 58,		-- Lorelei
		[411]	= 60,		-- Bruno
		[412]	= 62,		-- Agatha
		[413]	= 65,		-- Lance
	}
}

function ExtConstants:initializePaths(soullinkPath)
	self.PATHS.soullink = soullinkPath
	self.PATHS.screens = soullinkPath .. "screens" .. FileManager.slash
	self.PATHS.saves = soullinkPath .. "saves" .. FileManager.slash
end

return ExtConstants