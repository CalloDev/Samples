local StateMachine = {}
StateMachine.__index = StateMachine

function StateMachine.new(states)
    return setmetatable({
        Current = nil,
        States = states

    }, StateMachine)
end

function StateMachine:Change(stateName)
    if not self.States[stateName] then
        warn("No state found called: ", stateName)
        return
    end

    print("Changing to state: ", stateName)

    if self.Current and self.States[self.Current].Exit then
        self.States[self.Current].Exit()
    end

    self.Current = stateName

    if self.States[stateName].Enter then
        self.States[stateName].Enter()
    end
end

return StateMachine