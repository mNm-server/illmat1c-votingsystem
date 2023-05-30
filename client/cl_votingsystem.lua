-- Utilities
local VORPutils = {}
TriggerEvent("getUtils", function(utils)
    VORPutils = utils
end)

-- VORP
local VORPcore = {}
TriggerEvent("getCore", function(core)
    VORPcore = core
end)

-- MenuAPI
TriggerEvent("menuapi:getData",function(call)
    MenuData = call
end)
AddEventHandler('menuapi:closemenu', function() end)

-- Functions
local function split_with_comma(str)
    local fields = {}
    for field in str:gmatch('([^,]+)') do
      fields[#fields+1] = field
    end
    return fields
end

local function ViewPollResults(pollid, answers)
	VORPcore.NotifyRightTip("Awaiting results...",6000)
    MenuData.CloseAll()
    local elements = {}
    local AllAnswers = {}
    local Answers = split_with_comma(answers)
    VORPcore.RpcCall('GetBallots', function(result)
        if result then
            AllAnswers = result
        end
    end, pollid)
    Wait(100)
    for _,v in pairs(Answers) do
        local votes = 0
        for _,z in pairs(AllAnswers) do
            if v == tostring(z.ballotanswer) then
                votes = votes + 1
            end
        end
        Wait(2000)
        elements[#elements+1] = {label = votes.." - "..v, value = "close", desc = ""}
    end
    Wait(500)
    elements[#elements+1] = {label = Config.PollingStationExit, value = "close", desc = ""}
    MenuData.Open('default', GetCurrentResourceName(), 'ballot_select',{
        title    = Config.PollingStationName,
        subtext  = Config.PollingStationSubtext,
        align    = Config.PollingStationMenuAlignment,
        elements = elements,
    },
    function(data, menu)
        if data.current.value then
            if data.current.value ~= "close" then
                ClearPedTasks(PlayerPedId())
                menu.close()
            else
                ClearPedTasks(PlayerPedId())
                menu.close()
            end
        end
    end,
    function(data, menu)
        menu.close()
    end)
end

local function ManagePoll(pollid)
    MenuData.CloseAll()
    local elements = {}
    VORPcore.RpcCall('GetPollInformation', function(result)
        if result then
            elements[#elements+1] = {label = "View poll results", value = "pollingresults", value2 = result.answers, value3 = result.id, desc = ""}
            if result.active == 1 then
                elements[#elements+1] = {label = "Close Poll", value = "closepoll", value2 = result.id, desc = "Stop voting from taking place"}
            else
                elements[#elements+1] = {label = "Open Poll", value = "openpoll", value2 = result.id, desc = "Allow voting to take place"}
            end
            elements[#elements+1] = {label = "Created by: "..result.ballotcreator, value = "", desc = ""}
        end
    end, pollid)
    Wait(500)
    elements[#elements+1] = {label = Config.PollingStationExit, value = "close", desc = ""}
    MenuData.Open('default', GetCurrentResourceName(), 'ballot_select',{
        title    = Config.PollingStationName,
        subtext  = Config.PollingStationSubtext,
        align    = Config.PollingStationMenuAlignment,
        elements = elements,
    },
    function(data, menu)
        if data.current.value then
            if data.current.value == "pollingresults" then
                ViewPollResults(data.current.value3, data.current.value2)
            elseif data.current.value == "closepoll" then
                TriggerServerEvent('illmat1c-collection:pollmanagement', "close", data.current.value2)
                ClearPedTasks(PlayerPedId())
                menu.close()
            elseif data.current.value == "openpoll" then
                TriggerServerEvent('illmat1c-collection:pollmanagement', "open", data.current.value2)
                ClearPedTasks(PlayerPedId())
                menu.close()
            else
                ClearPedTasks(PlayerPedId())
                menu.close()
            end
        end
    end,
    function(data, menu)
        menu.close()
    end)
end

local function PollingMenu()
    MenuData.CloseAll()
    local elements = {}
    local MenuNumber = 1
    VORPcore.RpcCall('GetAllBallotQuestions', function(result)
        if result then
            for _,v in pairs(result) do
                elements[MenuNumber] = {label = "Question #"..v.id, value = v.id, desc = "Question: "..v.question}
                MenuNumber = MenuNumber + 1
            end
        end
    end)
    Wait(500)
    elements[#elements+1] = {label = Config.PollingStationExit, value = "close", desc = ""}
    MenuData.Open('default', GetCurrentResourceName(), 'ballot_select',{
        title    = Config.PollingStationName,
        subtext  = Config.PollingStationSubtext,
        align    = Config.PollingStationMenuAlignment,
        elements = elements,
    },
    function(data, menu)
        if data.current.value then
            if data.current.value ~= "close" then
               ManagePoll(data.current.value)
            else
                ClearPedTasks(PlayerPedId())
                menu.close()
            end
        end
    end,
    function(data, menu)
        menu.close()
    end)
end

local function BackOfficeMenu()
    MenuData.CloseAll()
    local elements = {}
    elements[#elements+1] = {label = "Add poll", value = "addpoll", desc = "Create a new poll"}
    elements[#elements+1] = {label = "Manage polls", value = "viewpolls", desc = "Adjust poll settings"}
    MenuData.Open('default', GetCurrentResourceName(), 'ballot_select',{
        title    = Config.PollingStationName,
        subtext  = Config.PollingStationSubtext,
        align    = Config.PollingStationMenuAlignment,
        elements = elements,
    },
    function(data, menu)
        if data.current.value then
            if data.current.value == "addpoll" then
                menu.close()
                local keyboard = exports["nh-keyboard"]:KeyboardInput({
                    header = "Add a Poll",
                    rows = {
                        {
                            id = 0,
                            txt = "Poll question"
                        },
                        {
                            id = 1,
                            txt = "Answers (Separated by comma)"
                        }
                    }
                })
                if keyboard ~= nil then
                    if keyboard[1].input == nil or keyboard[2].input == nil then return end
                    TriggerServerEvent('illmat1c-collection:addpoll', keyboard[1].input, keyboard[2].input)
                end
            elseif data.current.value == "viewpolls" then
                PollingMenu()
            else
                ClearPedTasks(PlayerPedId())
                menu.close()
            end
        end
    end,
    function(data, menu)
        menu.close()
    end)
end

local function VotingQuestion(table)
    MenuData.CloseAll()
    local elements = {}
    local MenuNumber = 1
    local answers = split_with_comma(table.answers)
    if answers then
        for _,v in pairs(answers) do
            elements[MenuNumber] = {label = v, value = v, value2 = table.id, desc = "Question: "..table.question}
            MenuNumber = MenuNumber + 1
        end
    end
    Wait(500)
    elements[#elements+1] = {label = "Close Polling Station", value = "close", desc = ""}
    MenuData.Open('default', GetCurrentResourceName(), 'ballot_select',{
        title    = Config.PollingStationName,
        subtext  = Config.PollingStationSubtext,
        align    = Config.PollingStationMenuAlignment,
        elements = elements,
    },
    function(data, menu)
        if data.current.value then
            if data.current.value ~= "close" then
                TriggerServerEvent("illmat1c-collection:votingsystemballotquestionanswered", data.current.value2, data.current.value)
                menu.close()
            else
                ClearPedTasks(PlayerPedId())
                menu.close()
            end
        end
    end,
    function(data, menu)
        menu.close()
    end)
end

local function VotingMenu()
    MenuData.CloseAll()
    local elements = {}
    local MenuNumber = 1
    VORPcore.RpcCall('GetAdminLevel', function(result)
        if result then
            elements[MenuNumber] = {label = "Backoffice", value = "backoffice", desc = "Administration desk to manage Polling"}
            MenuNumber = MenuNumber + 1
        end
    end)
    Wait(10)
    VORPcore.RpcCall('GetActiveBallotQuestions', function(result)
        if result then
            for _,v in pairs(result) do
                elements[MenuNumber] = {label = "Question #"..v.id, value = "ballot", value2 = v, desc = "Question: "..v.question}
                MenuNumber = MenuNumber + 1
            end
        end
    end)
    Wait(500)
    elements[#elements+1] = {label = Config.PollingStationExit, value = "close", desc = ""}
    MenuData.Open('default', GetCurrentResourceName(), 'ballot_select',{
        title    = Config.PollingStationName,
        subtext  = Config.PollingStationSubtext,
        align    = Config.PollingStationMenuAlignment,
        elements = elements,
    },
    function(data, menu)
        if data.current.value then
            if data.current.value == "ballot" then
                VotingQuestion(data.current.value2)
            elseif data.current.value == "backoffice" then
                BackOfficeMenu()
            else
                ClearPedTasks(PlayerPedId())
                menu.close()
            end
        end
    end,
    function(data, menu)
        menu.close()
    end)
end

-- Threads
local sleep = 1000
CreateThread(function()
    for _,v in pairs(Config.VotingBooths) do
        if v.Blip then
            local blip = VORPutils.Blips:SetBlip(v.Name, v.Blip, 0.2, v.Pos.x, v.Pos.y, v.Pos.z)
        end
        if v.NpcModel then
            local ped = VORPutils.Peds:Create(v.NpcModel, v.Pos.x, v.Pos.y, v.Pos.z - 1, 0, 'world', false)
            ped:SetHeading(v.Pos.w)
            ped:Freeze()
            ped:Invincible()
        end
    end
end)

CreateThread(function()
	local CityHall = VORPutils.Prompts:SetupPromptGroup()
	local CityHallPrompt = CityHall:RegisterPrompt(Config.VotingBoothPrompt, Config.VotingBoothPromptKey, 1, 1, true, 'hold', {timedeventhash = "SHORT_TIMED_EVENT_MP"})
    while true do
        sleep = 1500
        local coords = GetEntityCoords(PlayerPedId())
            for _, v in pairs(Config.VotingBooths) do
                local dist = #(coords - vector3( v.Pos.x, v.Pos.y, v.Pos.z - 1))
                if dist <= 10 then
                    sleep = 5
                end
                if dist < 1.5 then
                    CityHall:ShowGroup(Config.VotingBoothPromptGroup)
                end
            end
        if CityHallPrompt:HasCompleted() then
            VotingMenu()
        end
        Wait(sleep)
    end
end)
