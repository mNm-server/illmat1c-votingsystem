Config = {}
Config.DiscordLogging = {
    -- General settings
    Active = false,
    Webhook = "",
    Webhookavatar = "",

    -- Voting log
    PlayerHasVotedOn = "Player has voted on Poll # ",
    PlayersVote = "Vote cast: ",
    PlayersVoteColor = "blue",

    -- Poll created log
    PlayerCreatedPoll = "Player has created Poll # ",
    PlayerCreatedPollSub = "Question: ",
    PlayerCreatedColor = "green",

    -- Poll opening log
    PlayerReopenedPoll = "Player has reopened Poll # ",
    PlayerReopenedPollSub = "Voting can begin.",
    PlayerReopenedColor = "yellow",

    -- Poll closing log
    PlayerClosedPoll = "Player has closed Poll # ",
    PlayerClosedPollSub = "Voting has been stopped.",
    PlayerClosedColor = "red"
}

Config.Language = {
    VoteCast = "Thank you! Your vote has been cast!",
    VoteCastError = "An error has occured, please try again...",
    AlreadyCastVote = "You already voted on this Poll. You voted: ",
    ClosedPoll = "You have sucessfully closed the Poll!",
    OpenedPoll = "You have sucessfully reopened the Poll!",
    CreatedPoll = "You have successfully created a Poll #: ",
    PollFailed = "An error has occured, please try again...",
    PollNeedsName = "Requires a valid name for the Poll"
}

Config.PollingStationName = "Polling Station"           -- MenuAPI Title
Config.PollingStationSubtext = "Active Questions"       -- MenuAPI Subtext
Config.PollingStationExit = "Close Polling Station"     -- MenuAPI Close text
Config.PollingStationMenuAlignment = "top-right"        -- MenuAPI Location

Config.VotingBoothPromptKey = 0x760A9C6F                -- Key to open Prompt
Config.VotingBoothPrompt = "Vote"                       -- Top prompt text
Config.VotingBoothPromptGroup = "City Clerk"            -- Bottom prompt text

Config.VotingBooths = {
    [1] = {
        City = "Blackwater",                            -- Location name
        Name = "City Clerk",                            -- Blip name
        Blip = "blip_nominated",                        -- Blip icon / set to false if no blip is required
        NpcModel = "S_M_M_VHTDEALER_01",                -- NPC Model name / set to false to not spawn a NPC
        Pos = vector4(-810.389892578125, -1264.1529541015625, 43.73764419555664, 311.85287475586), -- NPC/Blip location
        Distance = 1.5,                                 -- Interaction distance
	},
    [2] = {
        City = "Saint Denis",
        Name = "City Clerk",
        NpcModel = false,
        Pos = vector4(2749.560791015625, -1399.707763671875, 46.24226379394531, 311.85287475586),
        Distance = 1.5,
        Blip = "blip_nominated",
	},
    [3] = {
        City = "Rhodes",
        Name = "City Clerk",
        NpcModel = false,
        Pos = vector4(1223.1072998046875, -1292.760009765625, 76.95761108398438, 311.85287475586),
        Distance = 1.5,
        Blip = "blip_nominated",
	},
    [4] = {
        City = "Annesburg",
        Name = "City Clerk",
        NpcModel = false,
        Pos = vector4(2951.423095703125, 1352.5543212890625, 44.91751480102539, 311.85287475586),
        Distance = 1.5,
        Blip = "blip_nominated",
	},
    [5] = {
        City = "Valentine",
        Name = "City Clerk",
        NpcModel = false,
        Pos = vector4(-255.6603546142578, 741.6355590820312, 118.21942138671876, 311.85287475586),
        Distance = 1.5,
        Blip = "blip_nominated",
	},
    [6] = {
        City = "Strawberry",
        Name = "City Clerk",
        NpcModel = false,
        Pos = vector4(-1778.343994140625, -374.99603271484375, 159.9600067138672, 311.85287475586),
        Distance = 1.5,
        Blip = "blip_nominated",
	},
    [7] = {
        City = "Armadillo",
        Name = "City Clerk",
        NpcModel = false,
        Pos = vector4(-3647.810302734375, -2549.4462890625, -12.88283061981201, 311.85287475586),
        Distance = 1.5,
        Blip = "blip_nominated",
	},
}
