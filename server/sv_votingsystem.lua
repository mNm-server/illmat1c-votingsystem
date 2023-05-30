-- VORP
local VORPcore = {}
TriggerEvent("getCore", function(core)
    VORPcore = core
end)

-- SQL loading
CreateThread(function()
    -- Initiate Table
    local table = MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `votingballots` (
          `characterid` int(11) DEFAULT NULL,
          `firstname` varchar(50) DEFAULT NULL,
          `lastname` varchar(50) DEFAULT NULL,
          `ballotnumber` int(11) DEFAULT NULL,
          `ballotanswer` varchar(50) DEFAULT NULL
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
        ]])
    if not table then
        print("ERROR: Failed to create votingballots table")
    end
    local table2 = MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `votingballots` (
          `characterid` int(11) DEFAULT NULL,
          `firstname` varchar(50) DEFAULT NULL,
          `lastname` varchar(50) DEFAULT NULL,
          `ballotnumber` int(11) DEFAULT NULL,
          `ballotanswer` varchar(50) DEFAULT NULL
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
        ]])
    if not table2 then
        print("ERROR: Failed to create votingballots table")
    end
end)

-- Functions
local function GetIdentity(source, identity)
    for _, v in pairs(GetPlayerIdentifiers(source)) do
        if string.sub(v, 1, string.len(identity .. ":")) == identity .. ":" then
            return v
        end
    end
end

local function Discord(title, description, color, source)
    local _source = source
    local identifier = GetPlayerIdentifier(_source)
    local steamName = GetPlayerName(_source)
    local discordIdentity = GetIdentity(_source, "discord")
    local discordId = string.sub(discordIdentity, 9)
    local message =
        "**Steam name: **`" ..steamName ..
        "`**\nIdentifier: **`" .. identifier ..
        "` \n**Discord:** <@" .. discordIdentity ..">"..
        " \n**DiscordId:** <@" .. discordId ..">"..
        " \n**Action:** `"..description.."`"
    VORPcore.AddWebhook(title, Config.DiscordLogging.Webhook, message)
end

-- Events
RegisterNetEvent('illmat1c-collection:votingsystemballotquestionanswered', function(ballotnumber, ballotanswer)
    local _source = source
    local Character = VORPcore.getUser(_source).getUsedCharacter
    local characterid = Character.charIdentifier
    local firstname = Character.firstname
    local lastname = Character.lastname
    local VotedCheck = MySQL.scalar.await('SELECT ballotanswer FROM votingballots WHERE characterid = ? AND ballotnumber = ?', {characterid, ballotnumber})
    if not VotedCheck then
        local Vote = MySQL.insert.await('INSERT INTO votingballots (characterid, firstname, lastname, ballotnumber, ballotanswer) VALUES (?,?,?,?,?)', {characterid, firstname, lastname, ballotnumber, ballotanswer})
        if Vote then
            VORPcore.NotifyRightTip(_source, Config.Language.VoteCast,4000)
            if Config.DiscordLogging.Active then
                Discord(Config.DiscordLogging.PlayerHasVotedOn..ballotnumber, Config.DiscordLogging.PlayersVote..ballotanswer, Config.DiscordLogging.PlayersVoteColor, _source)
            end
        else
            VORPcore.NotifyRightTip(_source, Config.Language.VoteCastError,4000)
        end
    else
        VORPcore.NotifyRightTip(_source, Config.Language.AlreadyCastVote..VotedCheck,4000)
    end
end)

RegisterNetEvent('illmat1c-collection:pollmanagement', function(status, pollid)
    local _source = source
    if status == "open" then
        local affectedRows = MySQL.update.await('UPDATE votingsystem SET active = ? WHERE id = ?', {1, pollid})
        if affectedRows then
            VORPcore.NotifyRightTip(_source, Config.Language.OpenedPoll,4000)
            if Config.DiscordLogging.Active then
                Discord(Config.DiscordLogging.PlayerReopenedPoll..pollid, Config.DiscordLogging.PlayerReopenedPollSub, Config.DiscordLogging.PlayerReopenedColor, _source)
            end
        end
    else
        local affectedRows = MySQL.update.await('UPDATE votingsystem SET active = ? WHERE id = ?', {0, pollid})
        if affectedRows then
            VORPcore.NotifyRightTip(_source, Config.Language.ClosedPoll,4000)
            if Config.DiscordLogging.Active then
                Discord(Config.DiscordLogging.PlayerClosedPoll..pollid, Config.DiscordLogging.PlayerClosedPollSub, Config.DiscordLogging.PlayerClosedColor, _source)
            end
        end
    end
end)

RegisterNetEvent('illmat1c-collection:addpoll', function(question, answers)
    local _source = source
    local PollID = MySQL.insert.await('INSERT INTO votingsystem (ballotcreator, question, active, answers) VALUES (?, ?, ?, ?)', {GetPlayerName(_source), question, 1, answers})
    if PollID then
        VORPcore.NotifyRightTip(_source, Config.Language.CreatedPoll..PollID,4000)
        if Config.DiscordLogging.Active then
            Discord(Config.DiscordLogging.PlayerCreatedPoll..PollID, Config.DiscordLogging.PlayerCreatedPollSub..question, Config.DiscordLogging.PlayerCreatedColor, _source)
        end
    else
        VORPcore.NotifyRightTip(_source, Config.Language.PollFailed,4000)
    end
end)

-- Callbacks
VORPcore.addRpcCallback("GetActiveBallotQuestions", function(source, cb)
    local result = MySQL.query.await('SELECT * FROM votingsystem WHERE active = ?', {1})
    if result then
        cb(result)
    else
        cb(false)
    end
end)

VORPcore.addRpcCallback("GetAllBallotQuestions", function(source, cb)
    local result = MySQL.query.await('SELECT * FROM votingsystem')
    if result then
        cb(result)
    else
        cb(false)
    end
end)

VORPcore.addRpcCallback("GetAdminLevel", function(source, cb)
    local _source = source
    local user = VorpCore.getUser(_source)
    if user.getGroup =='god' then
        cb(true)
    else
        cb(false)
    end
end)

VORPcore.addRpcCallback("GetPollInformation", function(source, cb, pollid)
    local Poll = MySQL.single.await('SELECT * FROM votingsystem WHERE id = ?',{pollid})
    if Poll then
        cb(Poll)
    else
        cb(false)
    end
end)

VORPcore.addRpcCallback("GetBallots", function(source, cb, pollid)
    local Ballots = MySQL.query.await('SELECT * FROM votingballots WHERE ballotnumber = ?',{pollid})
    if Ballots then
        cb(Ballots)
    else
        cb(false)
    end
end)
