LevelcapHandler = {
    highestBadge = 0,
    highestTrainer = 0
}

function LevelcapHandler:updateLevelCap()
    -- not fully tested
    local badgeList = TrackerAPI.getBadgeList()
    local highestBadge = self.highestBadgeIndex(badgeList)

    if highestBadge == 8 then
        self.highestTrainer = self.highestTrainerIndex()
    end

    self.highestBadge = highestBadge
end

function LevelcapHandler.highestTrainerIndex()
    local maxId = 0

    for id, levelcap in pairs(ExtConstants.LEVEL_CAP_BY_TRAINER_IDS_FRLG) do
        if TrackerAPI.hasDefeatedTrainer(id) then
            maxId = id
        end
    end
    return maxId
end

function LevelcapHandler.highestBadgeIndex(badges)
    badges = badges or {}
    local maxIdx = 0

    for i = 1, 8 do
        if badges[i] == true then
            maxIdx = i
        end
    end
    return maxIdx
end

return LevelcapHandler