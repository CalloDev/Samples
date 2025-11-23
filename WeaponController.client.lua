local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

local Remotes = ReplicatedStorage.Remotes.WeaponRemotes
local FireWeaponRemote = Remotes.FireWeapon
local ReloadWeaponRemote = Remotes.ReloadWeapon

local CurrentWeapon = nil
local CurrentCamera = workspace.CurrentCamera

local Assets = ReplicatedStorage.Assets
local Sounds = Assets.Sounds
local WeaponSounds = Sounds.Weapons

local function PlayWeaponSound(Weapon, SoundName)
    local Sound = WeaponSounds:FindFirstChild(Weapon.Name):FindFirstChild(SoundName)

    if not Sound then
        return
    end

    local SoundClone = Sound:Clone()
    SoundClone.Parent = Weapon:FindFirstChild("Muzzle")
    SoundClone:Play()

    game:GetService("Debris"):AddItem(SoundClone, SoundClone.TimeLength + 1)
end

local function FireWeapon()
    if not CurrentWeapon then
        return
    end

    local Origin = CurrentCamera.CFrame.Position
    local HitPosition = Mouse.Hit.Position or Origin + (CurrentCamera.CFrame.LookVector * 1000)
    local Direction = (HitPosition - Origin).Unit

    FireWeaponRemote:FireServer(CurrentWeapon.Name, Origin, Direction)
end

local function ReloadWeapon()
    if not CurrentWeapon then
        return
    end

    ReloadWeaponRemote:FireServer(CurrentWeapon.Name)
end    

Player.CharacterAdded:Connect(function(Character)
    Character.ChildAdded:Connect(function(Child)
        if Child:IsA("Tool") then
            Child.Equipped:Connect(function()
                CurrentWeapon = Child
            end)

            Child.Unequipped:Connect(function()
                if CurrentWeapon == Child then
                    CurrentWeapon = nil
                end
            end)
        end
    end)
end)

UserInputService.InputBegan:Connect(function(Input, GameProcessed)
    if GameProcessed then
        return
    end

    if not CurrentWeapon then
        return
    end

    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
        FireWeapon()
    elseif Input.KeyCode == Enum.KeyCode.R then
        ReloadWeapon()
    end
end)

FireWeaponRemote.OnClientEvent:Connect(function(Success)
    if Success then
        PlayWeaponSound(CurrentWeapon, "Fire")
    else
        PlayWeaponSound(CurrentWeapon, "Empty")
    end
end)
