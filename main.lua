local CurrentCamera = game:GetService("Workspace").CurrentCamera
local RunService = game:GetService("RunService")

local Describing = {
    ["3"] = "Big safe",
    ["2"] = "Small safe",
    ["1"] = "Cash register"
}
local Describing2 = {
    ["S1"] = "Pile",
    ["S2"] = "Pile",
    ["C1"] = "Crate",
}

getgenv().ESPSettings2 = {}

getgenv().ESPSettings2 = {
    RegisterSafesEnabled = false,
    NotBrokenColor = Color3.new(0, 255, 0),
    BrokenColor = Color3.new(255, 0, 0),
    ShowType3 = false,
    ShowType2 = false,
    ShowType1 = false,
    PilesCratesEnabled = false,
    ShowPiles = false,
    ShowCrates = false,
}
local ESPSettings2 = getgenv().ESPSettings2

local function CreateESP(Model)
    if not Model:FindFirstChild("Type") or not Model:FindFirstChild("Values") then
        return
    end

    local Object = Model.PrimaryPart

    local Type = Model:FindFirstChild("Type")
    local Values = Model:FindFirstChild("Values")
    local BrokenValue = Values:FindFirstChild("Broken")

    local Text = Drawing.new("Text")
    Text.Center = true
    Text.Visible = false
    Text.Outline = true
    Text.Color = Color3.new(0, 255, 0)
    Text.Size = 12
    
    local function UpdateESP()
        RunService.RenderStepped:Connect(function()
            local Position, OnScreen = CurrentCamera:WorldToViewportPoint(Object.Position)
            
            Text.Position = Position
            Text.Text = Describing[tostring(Type.Value)] or "Unknown"
            Text.Color = BrokenValue.Value and ESPSettings2.BrokenColor or ESPSettings2.NotBrokenColor

            Text.Visible = OnScreen and ESPSettings2.RegisterSafesEnabled and ESPSettings2["ShowType"..tostring(Type.Value)]
        end)
    end

    coroutine.wrap(UpdateESP)()
end

local function CreateESP2(Model)
    local Object = Model.PrimaryPart

    if not Object:FindFirstChild("Particle") then
        return
    end

    local ParticleObject = Object:FindFirstChild("Particle")
    local MainParticleColor = ParticleObject.Color.Keypoints[1].Value

    local Text = Drawing.new("Text")
    Text.Center = true
    Text.Visible = false
    Text.Outline = true
    Text.Color = Color3.new(255, 255, 255)
    Text.Size = 12
    
    local function UpdateESP()
        local Connection
        Connection = RunService.RenderStepped:Connect(function()
            local Position, OnScreen = CurrentCamera:WorldToViewportPoint(Object.Position)
            Text.Position = Position
            Text.Text = Describing2[tostring(Model.Name)] or "Unknown"
            Text.Color = MainParticleColor

            local ShowSetting = ESPSettings2["Show"..Describing2[tostring(Model.Name)].."s"] or true

            Text.Visible = OnScreen and ESPSettings2.PilesCratesEnabled and ShowSetting
        end)
        Model.Destroying:Connect(function()
            Connection:Disconnect()
            Text.Visible = false
            local Yes, No = pcall(function()
                Text:Remove()
            end)
        end)
    end

    coroutine.wrap(UpdateESP)()
end

for _,Model in pairs(workspace.Map.BredMakurz:GetChildren()) do
    CreateESP(Model)
end

for _,Model in pairs(workspace.Filter.SpawnedPiles:GetChildren()) do
    CreateESP2(Model)
end

workspace.Filter.SpawnedPiles.ChildAdded:Connect(function(Model)
    CreateESP2(Model)
end)

return ESPSettings2
