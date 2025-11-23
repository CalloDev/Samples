local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StateMachine = require(ReplicatedStorage.Shared.Utilities.StateMachine)

local RoundService = {}
RoundService.Config = require(script.RoundConfig)
RoundService.Timer = 0

local StateHandlers = {}
for _, module in ipairs(script.StateHandlers:GetChildren()) do
    local stateName = module.Name
    StateHandlers[stateName] = require(module)
end

local states = {}
for stateName, handler in pairs(StateHandlers) do
    states[stateName] = {
        Enter = function()
            handler.Enter(RoundService)
        end,

        Exit = function()
            handler.Exit(RoundService)
        end,
    }
end

RoundService.StateMachine = StateMachine.new(states)

function RoundService:SetTimer(seconds)
    self.Timer = seconds
end

function RoundService:ResetPlayers()
    for _, player in ipairs(Players:GetPlayers()) do
        player:LoadCharacter()
    end
end

function RoundService:GetPlayerCount()
    return #Players:GetPlayers()
end

function RoundService:HasEnoughPlayers()
    return self:GetPlayerCount() >= self.Config.MinimumPlayers
end

function RoundService:CheckPlayerCount()
    local currentState = self.StateMachine.Current

    if not self:HasEnoughPlayers() then
        if currentState ~= "WaitingForPlayers" then
            print("Not enough players: returning to waiting state")
            self.StateMachine:Change("WaitingForPlayers")
        end

        return
    end

    if currentState == "WaitingForPlayers" then
        print("Enough players: starting intermission")
        self.StateMachine:Change("Intermission")
    end
end

function RoundService:CheckTransition()
    if self.Timer == nil then
        return
    end

    if self.Timer > 0 then
        return
    end

    local currentState = self.StateMachine.Current

    if currentState == "Intermission" then
        RoundService.StateMachine:Change("InRound")

    elseif currentState == "InRound" then
        RoundService.StateMachine:Change("EndRound")

    elseif currentState == "EndRound" then
        RoundService.StateMachine:Change("Intermission")
    end
end

function RoundService:Tick()
    task.wait(1)

    if self.Timer ~= nil then
        self.Timer = self.Timer - 1
        self:CheckTransition()
    end

    task.defer(function()
        self:Tick()
    end)
end

function RoundService:StartTimerLoop()
    task.spawn(function()
        self:Tick()
    end)
end

function RoundService:Start()
    print("Starting RoundService")

    self.StateMachine:Change("WaitingForPlayers")

    self:CheckPlayerCount()
    self:StartTimerLoop()

    Players.PlayerAdded:Connect(function()
        self:CheckPlayerCount()
    end)

    Players.PlayerRemoving:Connect(function()
        self:CheckPlayerCount()
    end)
end

-- Automatically start the RoundService when this module is loaded
RoundService:Start()

return RoundService