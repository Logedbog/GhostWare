

--[Main Variables]

local plrs = game["Players"]
local rs = game["RunService"]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Teams = game:GetService("Teams")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")


local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local CurrentCamera = workspace.CurrentCamera
local plr = plrs.LocalPlayer
local mouse = plr:GetMouse()
local camera = workspace.CurrentCamera
local worldToViewportPoint = camera.worldToViewportPoint
local cc = Instance.new("ColorCorrectionEffect", game.Lighting)
local blur = Instance.new("BlurEffect", game.Lighting)
local sun = Instance.new("SunRaysEffect", game.Lighting)
local atmos = Instance.new("Atmosphere", game.Lighting)
blur.Size = 0
sun.Intensity = 0

--[Optimisation Variables]

local Drawingnew = Drawing.new
local Color3fromRGB = Color3.fromRGB
local Vector3new = Vector3.new
local Vector2new = Vector2.new
local mathfloor = math.floor
local mathceil = math.ceil

--[Setup Table]

local esp = {
    players = {},
    enabled = true,
    teamcheck = true,
    fontsize = 22,
    font = 0,
    settings = {
        name = {enabled = false, outline = true, color = Color3fromRGB(255, 255, 255), outlineColor = Color3fromRGB(0, 0, 0)},
        box = {enabled = false, outline = true, color = Color3fromRGB(255, 255, 255), outlineColor = Color3fromRGB(0, 0, 0)},
        healthbar = {enabled = false, outline = true, color = Color3fromRGB(255, 255, 255), outlineColor = Color3fromRGB(0, 0, 0)},
        healthtext = {enabled = false, outline = true, color = Color3fromRGB(255, 255, 255), outlineColor = Color3fromRGB(0, 0, 0)},
        distance = {enabled = false, outline = true, color = Color3fromRGB(255, 255, 255), outlineColor = Color3fromRGB(0, 0, 0)}
    }
}

esp.NewDrawing = function(type, properties)
    local newDrawing = Drawingnew(type)

    for i,v in next, properties or {} do
        newDrawing[i] = v
    end

    return newDrawing
end

esp.NewPlayer = function(v)
    esp.players[v] = {
        name = esp.NewDrawing("Text", {Color = Color3fromRGB(255, 255, 255), Outline = true, Center = true, Size = 13, Font = 0}),
        boxOutline = esp.NewDrawing("Square", {Color = Color3fromRGB(0, 0, 0), Thickness = 3}),
        box = esp.NewDrawing("Square", {Color = Color3fromRGB(255, 255, 255), Thickness = 1}),
        healthBarOutline = esp.NewDrawing("Line", {Color = Color3fromRGB(0, 0, 0), Thickness = 3}),
        healthBar = esp.NewDrawing("Line", {Color = Color3fromRGB(255, 255, 255), Thickness = 1}),
        healthText = esp.NewDrawing("Text", {Color = Color3fromRGB(255, 255, 255), Outline = true, Center = true, Size = 13, Font = 0}),
        distance = esp.NewDrawing("Text", {Color = Color3fromRGB(255, 255, 255), Outline = true, Center = true, Size = 13, Font = 0})
    }
end

for _,v in ipairs(plrs:GetPlayers()) do
    esp.NewPlayer(v)
end

plrs.PlayerAdded:Connect(function(v)
    esp.NewPlayer(v)
end)

plrs.PlayerRemoving:Connect(function(v)
    for i,v in pairs(esp.players[v]) do
        v:Remove()
    end
    esp.players[v] = nil
end)

local mainLoop = rs.RenderStepped:Connect(function()
    for i,v in pairs(esp.players) do
        if i ~= plr and i.Character and i.Character:FindFirstChild("Humanoid") and i.Character:FindFirstChild("HumanoidRootPart") and i.Character:FindFirstChild("Head") then
            local hum = i.Character.Humanoid
            local hrp = i.Character.HumanoidRootPart
            local head = i.Character.Head

            local Vector, onScreen = camera:WorldToViewportPoint(i.Character.HumanoidRootPart.Position)
    
            local Size = (camera:WorldToViewportPoint(hrp.Position - Vector3new(0, 3, 0)).Y - camera:WorldToViewportPoint(hrp.Position + Vector3new(0, 2.6, 0)).Y) / 2
            local BoxSize = Vector2new(mathfloor(Size * 1.5), mathfloor(Size * 1.9))
            local BoxPos = Vector2new(mathfloor(Vector.X - Size * 1.5 / 2), mathfloor(Vector.Y - Size * 1.6 / 2))
    
            local BottomOffset = BoxSize.Y + BoxPos.Y + 1

            if onScreen and esp.enabled then
                if esp.settings.name.enabled then
                    v.name.Position = Vector2new(BoxSize.X / 2 + BoxPos.X, BoxPos.Y - 16)
                    v.name.Outline = esp.settings.name.outline
                    v.name.Text = tostring(i)
                    v.name.Color = esp.settings.name.color
                    v.name.OutlineColor = esp.settings.name.outlineColor
                    v.name.Font = esp.font
                    v.name.Size = esp.fontsize

                    v.name.Visible = true
                else
                    v.name.Visible = false
                end

                if esp.settings.distance.enabled and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    v.distance.Position = Vector2new(BoxSize.X / 2 + BoxPos.X, BottomOffset)
                    v.distance.Outline = esp.settings.distance.outline
                    v.distance.Text = "[" .. mathfloor((hrp.Position - plr.Character.HumanoidRootPart.Position).Magnitude) .. "m]"
                    v.distance.Color = esp.settings.distance.color
                    v.distance.OutlineColor = esp.settings.distance.outlineColor
                    BottomOffset = BottomOffset + 15

                    v.distance.Font = esp.font
                    v.distance.Size = esp.fontsize

                    v.distance.Visible = true
                else
                    v.distance.Visible = false
                end

                if esp.settings.box.enabled then
                    v.boxOutline.Size = BoxSize
                    v.boxOutline.Position = BoxPos
                    v.boxOutline.Visible = esp.settings.box.outline
                    v.boxOutline.Color = esp.settings.box.outlineColor
    
                    v.box.Size = BoxSize
                    v.box.Position = BoxPos
                    v.box.Color = esp.settings.box.color
                    v.box.Visible = true
                else
                    v.boxOutline.Visible = false
                    v.box.Visible = false
                end

                if esp.settings.healthbar.enabled then
                    v.healthBar.From = Vector2new((BoxPos.X - 5), BoxPos.Y + BoxSize.Y)
                    v.healthBar.To = Vector2new(v.healthBar.From.X, v.healthBar.From.Y - (hum.Health / hum.MaxHealth) * BoxSize.Y)
                    v.healthBar.Color = esp.settings.healthbar.color
                    v.healthBar.Visible = true

                    v.healthBarOutline.From = Vector2new(v.healthBar.From.X, BoxPos.Y + BoxSize.Y + 1)
                    v.healthBarOutline.To = Vector2new(v.healthBar.From.X, (v.healthBar.From.Y - 1 * BoxSize.Y) -1)
                    v.healthBarOutline.Color = esp.settings.healthbar.outlineColor
                    v.healthBarOutline.Visible = esp.settings.healthbar.outline
                else
                    v.healthBarOutline.Visible = false
                    v.healthBar.Visible = false
                end

                if esp.settings.healthtext.enabled then
                    v.healthText.Text = tostring(mathfloor((hum.Health / hum.MaxHealth) * 100 + 0.5))
                    v.healthText.Position = Vector2new((BoxPos.X - 20), (BoxPos.Y + BoxSize.Y - 1 * BoxSize.Y) -1)
                    v.healthText.Color = esp.settings.healthtext.color
                    v.healthText.OutlineColor = esp.settings.healthtext.outlineColor
                    v.healthText.Outline = esp.settings.healthtext.outline

                    v.healthText.Font = esp.font
                    v.healthText.Size = esp.fontsize

                    v.healthText.Visible = true
                else
                    v.healthText.Visible = false
                end

                if esp.teamcheck then
                    if v.TeamColor ~= plr.TeamColor then
                        v.name.Visible = esp.settings.name.enabled
                        v.box.Visible = esp.settings.box.enabled
                        v.healthBar.Visible = esp.settings.healthbar.enabled
                        v.healthText.Visible = esp.settings.healthtext.enabled
                        v.distance.Visible = esp.settings.distance.enabled
                    else
                        v.name.Visible = false
                        v.boxOutline.Visible = false
                        v.box.Visible = false
                        v.healthBarOutline.Visible = false
                        v.healthBar.Visible = false
                        v.healthText.Visible = false
                        v.distance.Visible = false
                    end
                end
            else
                v.name.Visible = false
                v.boxOutline.Visible = false
                v.box.Visible = false
                v.healthBarOutline.Visible = false
                v.healthBar.Visible = false
                v.healthText.Visible = false
                v.distance.Visible = false
            end
        else
            v.name.Visible = false
            v.boxOutline.Visible = false
            v.box.Visible = false
            v.healthBarOutline.Visible = false
            v.healthBar.Visible = false
            v.healthText.Visible = false
            v.distance.Visible = false
        end
    end
end)

getgenv().esp = esp

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/vozoid/ui-libraries/main/drawing/void/source.lua"))()

local main = library:Load{
    Name = "GhostWare [CLOSED BETA]",
    SizeX = 500,
    SizeY = 450,
    Theme = "Midnight",
    Extension = "ghost", -- config file extension
    Folder = "ghostware" -- config folder name
}

local Aimbot = main:Tab("Aimbot")
local Exploits = main:Tab("Exploits")
local Visuals = main:Tab("Visuals")
local Misc = main:Tab("Misc")


-- Aimbot Tab
local Aimbott = Aimbot:Section{
    Name = "Aimbot",
    Side = "Left"
}


Aimbott:Button{
    Name = "Aimbot",
    Callback  = function()
        loadstring(game:HttpGet(('https://raw.githubusercontent.com/Logedbog/GhostWare/main/GhostWareAimbot.lua'),true))()
    end
}




-- Exploits Tab
local PlayerMods = Exploits:Section{
    Name = "PlayerMods",
    Side = "Left"
}

PlayerMods:Button{
    Name = "God Mode",
    Callback  = function()
        LocalPlayer.Character.Humanoid.Parent = nil
	Instance.new("Humanoid", LocalPlayer.Character)
    end
}


PlayerMods:Button{
    Name = "Semi-God",
    Callback  = function()
        ReplicatedStorage.Events.FallDamage:FireServer(0/0)
	LocalPlayer.Character.Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
		LocalPlayer.Character.Humanoid.Health = 100
	end)
    end
}


PlayerMods:Button{
    Name = "Invisible",
    Callback  = function()
        local oldpos = LocalPlayer.Character.HumanoidRootPart.CFrame
	LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(9999,9999,9999)
	local NewRoot = LocalPlayer.Character.LowerTorso.Root:Clone()
	LocalPlayer.Character.LowerTorso.Root:Destroy()
	NewRoot.Parent = LocalPlayer.Character.LowerTorso
	wait()
	LocalPlayer.Character.HumanoidRootPart.CFrame = oldpos
    end
}


local toggle = PlayerMods:Toggle{
    Name = "Unlock Reset",
    Flag = "Reset 1",
    --Default = true,
    Callback  = function(bool)
       game:GetService("StarterGui"):SetCore("ResetButtonCallback", bool)
    end
}


local Sounds = Exploits:Section{
    Name = "Sounds",
    Side = "Right"
}

local label = Sounds:Label("Hit Sound")


local box = Sounds:Box{
    Name = "Hit Sound",
    --Default = "hi",
    Placeholder = "Roblox Sound ID",
    Flag = "Box 1",
    Callback = function(HitSound)
        print("Hit Sound is now " .. HitSound)
    end
}


local label = Sounds:Label("Kill Sound")


local box = Sounds:Box{
    Name = "Kill Sound",
    --Default = "hi",
    Placeholder = "Roblox Sound ID",
    Flag = "Box 1",
    Callback = function(KillSound)
        print("Kill Sound is now " .. KillSound)
    end
}


-- Visual Tab
local EspSection = Visuals:Section{
    Name = "ESP",
    Side = "Left"
}

local WorldSection = Visuals:Section{
    Name = "World",
    Side = "Right"
}

local ChamsSection = Visuals:Section{
    Name = "Chams",
    Side = "Left"
}

local VMiscSection = Visuals:Section{
    Name = "Misc",
    Side = "Left"
}

-- Misc Tab

local Close = Misc:Section{
    Name = "Close / Open",
    Side = "Left"
}


-- Esp 

-- Box Toggle
local BoxT = EspSection:Toggle{
    Name = "Box",
    Flag = "box",
    --Default = false,
    Callback  = function(bool)
        esp.settings.box.enabled = bool
    end
}

local togglepicker1 = BoxT:ColorPicker{
    Default = Color3.fromRGB(255, 255, 255), 
    Flag = "boxcolor", 
    Callback = function(color)
        esp.settings.box.color = color
    end
}

local togglepicker2 = BoxT:ColorPicker{
    Default = Color3.fromRGB(0, 0, 0), 
    Flag = "boxoutline", 
    Callback = function(color)
        esp.settings.box.outlineColor = color
    end
}
-- Name Toggle
local NameT = EspSection:Toggle{
    Name = "Name",
    Flag = "name",
    --Default = false,
    Callback  = function(bool)
        esp.settings.name.enabled = bool
    end
}

local togglepicker1 = NameT:ColorPicker{
    Default = Color3.fromRGB(255, 255, 255), 
    Flag = "nameolor", 
    Callback = function(color)
        esp.settings.name.color = color
    end
}

local togglepicker2 = NameT:ColorPicker{
    Default = Color3.fromRGB(0, 0, 0), 
    Flag = "nameoutline", 
    Callback = function(color)
        esp.settings.name.outlineColor = color
    end
}
-- HealthBar Toggle
local HealthBT = EspSection:Toggle{
    Name = "HealthBar",
    Flag = "healthb",
    --Default = false,
    Callback  = function(bool)
        esp.settings.healthbar.enabled = bool
    end
}

local togglepicker1 = HealthBT:ColorPicker{
    Default = Color3.fromRGB(255, 255, 255), 
    Flag = "healtbcolor", 
    Callback = function(color)
        esp.settings.healthbar.color = color
    end
}

local togglepicker2 = HealthBT:ColorPicker{
    Default = Color3.fromRGB(0, 0, 0), 
    Flag = "healtboutline", 
    Callback = function(color)
        esp.settings.healthbar.outlineColor = color
    end
}
-- HealthText Toggle
local HealthTT = EspSection:Toggle{
    Name = "HealthText",
    Flag = "healtht",
    --Default = false,
    Callback  = function(bool)
        esp.settings.healthtext.enabled = bool
    end
}

local togglepicker1 = HealthTT:ColorPicker{
    Default = Color3.fromRGB(255, 255, 255), 
    Flag = "healttcolor", 
    Callback = function(color)
        esp.settings.healthtext.color = color
    end
}

local togglepicker2 = HealthTT:ColorPicker{
    Default = Color3.fromRGB(0, 0, 0), 
    Flag = "healttoutline", 
    Callback = function(color)
        esp.settings.healthtext.outlineColor = color
    end
}
-- Distance Toggle
local DistanceT = EspSection:Toggle{
    Name = "Distance",
    Flag = "distancet",
    --Default = false,
    Callback  = function(bool)
        esp.settings.distance.enabled = bool
    end
}

local togglepicker1 = DistanceT:ColorPicker{
    Default = Color3.fromRGB(255, 255, 255), 
    Flag = "distancecolor", 
    Callback = function(color)
        esp.settings.distance.color = color
    end
}

local togglepicker2 = DistanceT:ColorPicker{
    Default = Color3.fromRGB(0, 0, 0), 
    Flag = "distanceoutline", 
    Callback = function(color)
        esp.settings.distance.outlineColor = color
    end
}

local TeamCheckT = EspSection:Toggle{
    Name = "Team Check",
    Flag = "teamt",
    Default = false,
    Callback  = function(bool)
        esp.teamcheck = bool
    end
}

-- Chams

local ChamsT = ChamsSection:Toggle{
    Name = "Visible Chams",
    Flag = "chamst",
    Default = false,
    Callback  = function(bool)
        print("Vchams enabled")
    end
}

local togglepicker1 = ChamsT:ColorPicker{
    Default = Color3.fromRGB(255, 255, 255), 
    Flag = "chamscolor", 
    Callback = function(color)
        print(color)
    end
}


local ChamsTrans = ChamsSection:Slider{
    Name = "Visible Chams Transparency",
    Text = "[value]/1",
    Default = 1,
    Min = 0,
    Max = 1,
    Float = 0.1,
    Flag = "Chams 1",
    Callback = function(value)
        print("Vchams Transparency : ".. value)
    end
}

local InvChamsT = ChamsSection:Toggle{
    Name = "Invisible Chams",
    Flag = "invchamst",
    Default = false,
    Callback  = function(bool)
        print("Invchams enabled")
    end
}

local togglepicker1 = InvChamsT:ColorPicker{
    Default = Color3.fromRGB(255, 255, 255), 
    Flag = "invchamscolor", 
    Callback = function(color)
        print(color)
    end
}

local InvChamsTrans = ChamsSection:Slider{
    Name = "Invisible Chams Transparency",
    Text = "[value]/1",
    Default = 1,
    Min = 0,
    Max = 1,
    Float = 0.1,
    Flag = "InvChams 1",
    Callback = function(value)
        print("Invchams Transparency : ".. value)
    end
}

-- World

local BrightnessS = WorldSection:Slider{
    Name = "Brightness",
    Text = "[value]/1",
    Default = 0,
    Min = -1,
    Max = 1,
    Float = 0.1,
    Flag = "Slider 1",
    Callback = function(value)
        cc.Brightness = value
    end
}

local ContrastS = WorldSection:Slider{
    Name = "Contrast",
    Text = "[value]/1",
    Default = 0,
    Min = -1,
    Max = 1,
    Float = 0.1,
    Flag = "Slider 1",
    Callback = function(value)
        cc.Contrast = value
    end
}

local SaturationS = WorldSection:Slider{
    Name = "Saturation",
    Text = "[value]/1",
    Default = 0,
    Min = -1,
    Max = 1,
    Float = 0.1,
    Flag = "Slider 1",
    Callback = function(value)
        cc.Saturation = value
    end
}

local BlurS = WorldSection:Slider{
    Name = "Blur",
    Text = "[value]/30",
    Default = 0,
    Min = 0,
    Max = 30,
    Float = 0.1,
    Flag = "Slider 1",
    Callback = function(value)
        blur.Size = value
    end
}

local SunS = WorldSection:Slider{
    Name = "Sun Rays",
    Text = "[value]/1",
    Default = 0,
    Min = 0,
    Max = 1,
    Float = 0.1,
    Flag = "Slider 1",
    Callback = function(value)
        sun.Intensity = value
    end
}

local WorldColor = WorldSection:ColorPicker{
    Name = "World Color",
    Default = Color3.fromRGB(255, 255, 255),
    Flag = "worldP",
    Callback = function(color)
        cc.TintColor = color
    end
}

local FogColor = WorldSection:ColorPicker{
    Name = "Fog Color",
    Default = Color3.fromRGB(255, 255, 255),
    Flag = "fogP",
    Callback = function(color)
        atmos.Color = color
    end
}

local FogS = WorldSection:Slider{
    Name = "Fog Intensity",
    Text = "[value]/10",
    Default = 0,
    Min = 0,
    Max = 10,
    Float = 0.2,
    Flag = "RogS 1",
    Callback = function(value)
        atmos.Haze = value
    end
}

local SkyboxD = WorldSection:Dropdown{
    Name = "Skybox",
    Default = "Default",
    Content = {
        "Default",
        "Nebula",
        "Random One"
    },
    Flag = "skybox",
    Callback = function(option)
        print(option)
    end
}

-- Visuals Misc

local FOVS = VMiscSection:Slider{
    Name = "FOV",
    Text = "[value]/120",
    Default = 70,
    Min = 70,
    Max = 120,
    Float = 2,
    Flag = "FovS 1",
    Callback = function(value)
        camera.FieldOfView = value
    end
}

local ThirdpersonK = VMiscSection:Keybind{
    Name = "ThirdPerson",
    Default = Enum.KeyCode.X,
    Blacklist = {Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2},
    Flag = "thirdpersonk",
    Callback = function(key, fromsetting)
  
    end
}

-- Misc

local keybind = Close:Keybind{
    Name = "Toggle UI",
    Default = Enum.KeyCode.End,
    Blacklist = {Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2},
    Flag = "Keybind 1",
    Callback = function(key, fromsetting)
        if fromsetting then
        else
            library:Close()
        end
    end
}

local MiscSettings = Misc:Section{
    Name = "Unload",
    Side = "Left"
}

MiscSettings:Button{
    Name = "kill GhostWare Made  by Logedbog",
    Callback  = function()
       library:Unload()
    end
}


--library:SaveConfig("config", true) -- universal config
--library:SaveConfig("config") -- game specific config
--library:DeleteConfig("config", true) -- universal config
--library:DeleteConfig("config") -- game specific config
--library:GetConfigs(true) -- return universal and game specific configs (table)
--library:GetConfigs() -- return game specific configs (table)
--library:LoadConfig("config", true) -- load universal config
--library:LoadConfig("config") -- load game specific config

local configs = main:Tab("Settings")

local themes = configs:Section{Name = "Theme", Side = "Left"}

local themepickers = {}

local themelist = themes:Dropdown{
    Name = "Theme",
    Default = library.currenttheme,
    Content = library:GetThemes(),
    Flag = "Theme Dropdown",
    Callback = function(option)
        if option then
            library:SetTheme(option)

            for option, picker in next, themepickers do
                picker:Set(library.theme[option])
            end
        end
    end
}

library:ConfigIgnore("Theme Dropdown")

local namebox = themes:Box{
    Name = "Custom Theme Name",
    Placeholder = "Custom Theme",
    Flag = "Custom Theme"
}

library:ConfigIgnore("Custom Theme")

themes:Button{
    Name = "Save Custom Theme",
    Callback = function()
        if library:SaveCustomTheme(library.flags["Custom Theme"]) then
            themelist:Refresh(library:GetThemes())
            themelist:Set(library.flags["Custom Theme"])
            namebox:Set("")
        end
    end
}

local customtheme = configs:Section{Name = "Custom Theme", Side = "Right"}

themepickers["Accent"] = customtheme:ColorPicker{
    Name = "Accent",
    Default = library.theme["Accent"],
    Flag = "Accent",
    Callback = function(color)
        library:ChangeThemeOption("Accent", color)
    end
}

library:ConfigIgnore("Accent")

themepickers["Window Background"] = customtheme:ColorPicker{
    Name = "Window Background",
    Default = library.theme["Window Background"],
    Flag = "Window Background",
    Callback = function(color)
        library:ChangeThemeOption("Window Background", color)
    end
}

library:ConfigIgnore("Window Background")

themepickers["Window Border"] = customtheme:ColorPicker{
    Name = "Window Border",
    Default = library.theme["Window Border"],
    Flag = "Window Border",
    Callback = function(color)
        library:ChangeThemeOption("Window Border", color)
    end
}

library:ConfigIgnore("Window Border")

themepickers["Tab Background"] = customtheme:ColorPicker{
    Name = "Tab Background",
    Default = library.theme["Tab Background"],
    Flag = "Tab Background",
    Callback = function(color)
        library:ChangeThemeOption("Tab Background", color)
    end
}

library:ConfigIgnore("Tab Background")

themepickers["Tab Border"] = customtheme:ColorPicker{
    Name = "Tab Border",
    Default = library.theme["Tab Border"],
    Flag = "Tab Border",
    Callback = function(color)
        library:ChangeThemeOption("Tab Border", color)
    end
}

library:ConfigIgnore("Tab Border")

themepickers["Tab Toggle Background"] = customtheme:ColorPicker{
    Name = "Tab Toggle Background",
    Default = library.theme["Tab Toggle Background"],
    Flag = "Tab Toggle Background",
    Callback = function(color)
        library:ChangeThemeOption("Tab Toggle Background", color)
    end
}

library:ConfigIgnore("Tab Toggle Background")

themepickers["Section Background"] = customtheme:ColorPicker{
    Name = "Section Background",
    Default = library.theme["Section Background"],
    Flag = "Section Background",
    Callback = function(color)
        library:ChangeThemeOption("Section Background", color)
    end
}

library:ConfigIgnore("Section Background")

themepickers["Section Border"] = customtheme:ColorPicker{
    Name = "Section Border",
    Default = library.theme["Section Border"],
    Flag = "Section Border",
    Callback = function(color)
        library:ChangeThemeOption("Section Border", color)
    end
}

library:ConfigIgnore("Section Border")

themepickers["Text"] = customtheme:ColorPicker{
    Name = "Text",
    Default = library.theme["Text"],
    Flag = "Text",
    Callback = function(color)
        library:ChangeThemeOption("Text", color)
    end
}

library:ConfigIgnore("Text")

themepickers["Disabled Text"] = customtheme:ColorPicker{
    Name = "Disabled Text",
    Default = library.theme["Disabled Text"],
    Flag = "Disabled Text",
    Callback = function(color)
        library:ChangeThemeOption("Disabled Text", color)
    end
}

library:ConfigIgnore("Disabled Text")

themepickers["Object Background"] = customtheme:ColorPicker{
    Name = "Object Background",
    Default = library.theme["Object Background"],
    Flag = "Object Background",
    Callback = function(color)
        library:ChangeThemeOption("Object Background", color)
    end
}

library:ConfigIgnore("Object Background")

themepickers["Object Border"] = customtheme:ColorPicker{
    Name = "Object Border",
    Default = library.theme["Object Border"],
    Flag = "Object Border",
    Callback = function(color)
        library:ChangeThemeOption("Object Border", color)
    end
}

library:ConfigIgnore("Object Border")

themepickers["Dropdown Option Background"] = customtheme:ColorPicker{
    Name = "Dropdown Option Background",
    Default = library.theme["Dropdown Option Background"],
    Flag = "Dropdown Option Background",
    Callback = function(color)
        library:ChangeThemeOption("Dropdown Option Background", color)
    end
}

library:ConfigIgnore("Dropdown Option Background")

local configsection = configs:Section{Name = "Configs", Side = "Left"}

local configlist = configsection:Dropdown{
    Name = "Configs",
    Content = library:GetConfigs(), -- GetConfigs(true) if you want universal configs
    Flag = "Config Dropdown"
}

library:ConfigIgnore("Config Dropdown")

local loadconfig = configsection:Button{
    Name = "Load Config",
    Callback = function()
        library:LoadConfig(library.flags["Config Dropdown"]) -- LoadConfig(library.flags["Config Dropdown"], true)  if you want universal configs
    end
}

local delconfig = configsection:Button{
    Name = "Delete Config",
    Callback = function()
        library:DeleteConfig(library.flags["Config Dropdown"]) -- DeleteConfig(library.flags["Config Dropdown"], true)  if you want universal configs
        configlist:Refresh(library:GetConfigs())
    end
}


local configbox = configsection:Box{
    Name = "Config Name",
    Placeholder = "Config Name",
    Flag = "Config Name"
}

library:ConfigIgnore("Config Name")

local save = configsection:Button{
    Name = "Save Config",
    Callback = function()
        library:SaveConfig(library.flags["Config Name"]) -- SaveConfig(library.flags["Config Name"], true) if you want universal configs
        configlist:Refresh(library:GetConfigs())
    end
}



--Functions
--HitSound
LocalPlayer.Additionals.TotalDamage.Changed:Connect(function(val)
	if HitSound ~= "" and HitSound ~= 0 then
		local marker = Instance.new("Sound")
		marker.Parent = game:GetService("SoundService")
		marker.SoundId = "rbxassetid://"..HitSound
		marker.Volume = 3
		marker:Play()
	end
end)

--KillSound
LocalPlayer.Status.Kills.Changed:Connect(function(val)
	if KillSound ~= "" and KillSound ~= 0 then
		local marker = Instance.new("Sound")
		marker.Parent = game:GetService("SoundService")
		marker.SoundId = "rbxassetid://"..KillSound
		marker.Volume = 3
		marker:Play()
	end
end)


