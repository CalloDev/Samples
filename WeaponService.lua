local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local weaponsFolder = ReplicatedStorage.Shared.Weapons
local FireWeaponRemote = ReplicatedStorage.Remotes.WeaponRemotes.FireWeapon
local ReloadWeaponRemote = ReplicatedStorage.Remotes.WeaponRemotes.ReloadWeapon

local WeaponService = {}
WeaponService.PlayerWeapons = {}
WeaponService.WeaponModules = {}

for _, weaponModule in pairs(weaponsFolder:GetChildren()) do
    if weaponModule:IsA("ModuleScript") then
        local weaponName = weaponModule.Name
        WeaponService.WeaponModules[weaponName] = require(weaponModule)
    end
end

function WeaponService:GetWeapon(Player, WeaponName)
    self.PlayerWeapons[Player] = self.PlayerWeapons[Player] or {}

    if not self.PlayerWeapons[Player][WeaponName] then
        local weaponModule = self.WeaponModules[WeaponName]

        if weaponModule then
            self.PlayerWeapons[Player][WeaponName] = weaponModule.new(Player)
        else
            warn("Weapon module not found: " .. WeaponName)
            return
        end
    end

    return self.PlayerWeapons[Player][WeaponName]
end

FireWeaponRemote.OnServerEvent:Connect(function(Player, WeaponName, Origin, Direction)
    local weapon = WeaponService:GetWeapon(Player, WeaponName)

    local CanFire, Reason = weapon:CanFire()

    if weapon and CanFire and Reason == "Fire" then
        weapon:Shoot(Origin, Direction)

        FireWeaponRemote:FireClient(Player, true)
    elseif Reason == "Empty" then
        FireWeaponRemote:FireClient(Player, false)
    end
end)

ReloadWeaponRemote.OnServerEvent:Connect(function(Player, WeaponName)
    local weapon = WeaponService:GetWeapon(Player, WeaponName)

    if weapon then
        weapon:Reload()
    end
end)

Players.PlayerRemoving:Connect(function(Player)
    WeaponService.PlayerWeapons[Player] = nil
end)

return WeaponService
