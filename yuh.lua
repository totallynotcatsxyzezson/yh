
local Aiming = loadstring(game:HttpGet("https://raw.githubusercontent.com/lolimluke/silent2/main/stefanuk"))()
Aiming.TeamCheck(false)

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local CurrentCamera = Workspace.CurrentCamera

local DaHoodSettings = {
    SilentAim = true,
    AimLock = false,
    Prediction = 0.157,
    AimLockKeybind = Enum.KeyCode.E
}
getgenv().DaHoodSettings = DaHoodSettings

function Aiming.Check()
    if not (Aiming.Enabled == true and Aiming.Selected ~= LocalPlayer and Aiming.SelectedPart ~= nil) then
        return false
    end

    local Character = Aiming.Character(Aiming.Selected)
    local KOd = Character:WaitForChild("BodyEffects")["K.O"].Value
    local Grabbed = Character:FindFirstChild("GRABBING_CONSTRAINT") ~= nil

    if (KOd or Grabbed) then
        return false
    end

    return true
end

local __index
__index = hookmetamethod(game, "__index", function(t, k)
    if (t:IsA("Mouse") and (k == "Hit" or k == "Target") and Aiming.Check()) then
        local SelectedPart = Aiming.SelectedPart

        if (DaHoodSettings.SilentAim and (k == "Hit" or k == "Target")) then
            local Hit = SelectedPart.CFrame + (SelectedPart.Velocity * DaHoodSettings.Prediction)

            return (k == "Hit" and Hit or SelectedPart)
        end
    end

    return __index(t, k)
end)

RunService:BindToRenderStep("AimLock", 0, function()
    if (DaHoodSettings.AimLock and Aiming.Check() and UserInputService:IsKeyDown(DaHoodSettings.AimLockKeybind)) then
        local SelectedPart = Aiming.SelectedPart

        local Hit = SelectedPart.CFrame + (SelectedPart.Velocity * DaHoodSettings.Prediction)

        CurrentCamera.CFrame = CFrame.lookAt(CurrentCamera.CFrame.Position, Hit.Position)
    end
    end)


wait(0.1)


getgenv().AimPart = "HumanoidRootPart" -- For R15 Games: {UpperTorso, LowerTorso, HumanoidRootPart, Head} | For R6 Games: {Head, Torso, HumanoidRootPart}
getgenv().AimlockKey = "q"
getgenv().AimRadius = 30 -- How far away from someones character you want to lock on at
getgenv().ThirdPerson = false 
getgenv().FirstPerson = false
getgenv().TeamCheck = false -- Check if Target is on your Team (True means it wont lock onto your teamates, false is vice versa) (Set it to false if there are no teams)
getgenv().PredictMovement = true -- Predicts if they are moving in fast velocity (like jumping) so the aimbot will go a bit faster to match their speed 
getgenv().PredictionVelocity = 9
getgenv().AutoPredictionAimlock = false
getgenv().Notify = false



local Players, Uis, RService, SGui = game:GetService"Players", game:GetService"UserInputService", game:GetService"RunService", game:GetService"StarterGui";
local Client, Mouse, Camera, CF, RNew, Vec3, Vec2 = Players.LocalPlayer, Players.LocalPlayer:GetMouse(), workspace.CurrentCamera, CFrame.new, Ray.new, Vector3.new, Vector2.new;
local Aimlock, MousePressed, CanNotify = true, false, false;
local AimlockTarget;

getgenv().CiazwareUniversalAimbotLoaded = true

getgenv().WorldToViewportPoint = function(P)
	return Camera:WorldToViewportPoint(P)
end

getgenv().WorldToScreenPoint = function(P)
	return Camera.WorldToScreenPoint(Camera, P)
end

getgenv().GetObscuringObjects = function(T)
	if T and T:FindFirstChild(getgenv().AimPart) and Client and Client.Character:FindFirstChild("Head") then 
		local RayPos = workspace:FindPartOnRay(RNew(
			T[getgenv().AimPart].Position, Client.Character.Head.Position)
		)
		if RayPos then return RayPos:IsDescendantOf(T) end
	end
end

getgenv().GetNearestTarget = function()
	-- Credits to whoever made this, i didnt make it, and my own mouse2plr function kinda sucks
	local players = {}
	local PLAYER_HOLD  = {}
	local DISTANCES = {}
	for i, v in pairs(Players:GetPlayers()) do
		if v ~= Client then
			table.insert(players, v)
		end
	end
	for i, v in pairs(players) do
		if v.Character ~= nil then
			local AIM = v.Character:FindFirstChild("Head")
			if getgenv().TeamCheck == true and v.Team ~= Client.Team then
				local DISTANCE = (v.Character:FindFirstChild("Head").Position - game.Workspace.CurrentCamera.CFrame.p).magnitude
				local RAY = Ray.new(game.Workspace.CurrentCamera.CFrame.p, (Mouse.Hit.p - game.Workspace.CurrentCamera.CFrame.p).unit * DISTANCE)
				local HIT,POS = game.Workspace:FindPartOnRay(RAY, game.Workspace)
				local DIFF = math.floor((POS - AIM.Position).magnitude)
				PLAYER_HOLD[v.Name .. i] = {}
				PLAYER_HOLD[v.Name .. i].dist= DISTANCE
				PLAYER_HOLD[v.Name .. i].plr = v
				PLAYER_HOLD[v.Name .. i].diff = DIFF
				table.insert(DISTANCES, DIFF)
			elseif getgenv().TeamCheck == false and v.Team == Client.Team then 
				local DISTANCE = (v.Character:FindFirstChild("Head").Position - game.Workspace.CurrentCamera.CFrame.p).magnitude
				local RAY = Ray.new(game.Workspace.CurrentCamera.CFrame.p, (Mouse.Hit.p - game.Workspace.CurrentCamera.CFrame.p).unit * DISTANCE)
				local HIT,POS = game.Workspace:FindPartOnRay(RAY, game.Workspace)
				local DIFF = math.floor((POS - AIM.Position).magnitude)
				PLAYER_HOLD[v.Name .. i] = {}
				PLAYER_HOLD[v.Name .. i].dist= DISTANCE
				PLAYER_HOLD[v.Name .. i].plr = v
				PLAYER_HOLD[v.Name .. i].diff = DIFF
				table.insert(DISTANCES, DIFF)
			end
		end
	end
	
	if unpack(DISTANCES) == nil then
		return nil
	end
	
	local L_DISTANCE = math.floor(math.min(unpack(DISTANCES)))
	if L_DISTANCE > getgenv().AimRadius then
		return nil
	end
	
	for i, v in pairs(PLAYER_HOLD) do
		if v.diff == L_DISTANCE then
			return v.plr
		end
	end
	return nil
end

Mouse.KeyDown:Connect(function(a)
	if a == AimlockKey and AimlockTarget == nil then
		pcall(function()
			if MousePressed ~= true then MousePressed = true end 
			local Target;Target = GetNearestTarget()
			if Target ~= nil then 
				AimlockTarget = Target
                if getgenv().Notify == true then
                    if getgenv().Notify == true then
                        Notify({
                            Title = "cats.xyz",
                            Description = "imbecile: " .. tostring(AimlockTarget), "",
                            Duration = 3
                        })
                    end
                end
			end
		end)


	elseif a == AimlockKey and AimlockTarget ~= nil then
		if AimlockTarget ~= nil then AimlockTarget = nil end
		if MousePressed ~= false then 


			MousePressed = false 
		end
	end
end)

















RService.RenderStepped:Connect(function()
	if getgenv().ThirdPerson == true and getgenv().FirstPerson == true then 
		if (Camera.Focus.p - Camera.CoordinateFrame.p).Magnitude > 1 or (Camera.Focus.p - Camera.CoordinateFrame.p).Magnitude <= 1 then 
			CanNotify = true 
		else 
			CanNotify = false 
		end
	elseif getgenv().ThirdPerson == true and getgenv().FirstPerson == false then 
		if (Camera.Focus.p - Camera.CoordinateFrame.p).Magnitude > 1 then 
			CanNotify = true 
		else 
			CanNotify = false 
		end
	elseif getgenv().ThirdPerson == false and getgenv().FirstPerson == true then 
		if (Camera.Focus.p - Camera.CoordinateFrame.p).Magnitude <= 1 then 
			CanNotify = true 
		else 
			CanNotify = false 
		end
	end
	if Aimlock == true and MousePressed == true then 
		if AimlockTarget and AimlockTarget.Character and AimlockTarget.Character:FindFirstChild(getgenv().AimPart) then 
			if getgenv().FirstPerson == true then
				if CanNotify == true then
					if getgenv().PredictMovement == true then 
						Camera.CFrame = CF(Camera.CFrame.p, AimlockTarget.Character[getgenv().AimPart].Position + AimlockTarget.Character[getgenv().AimPart].Velocity/PredictionVelocity)
					elseif getgenv().PredictMovement == false then 
						Camera.CFrame = CF(Camera.CFrame.p, AimlockTarget.Character[getgenv().AimPart].Position)
					end
				end
			elseif getgenv().ThirdPerson == true then 
				if CanNotify == true then
					if getgenv().PredictMovement == true then 
						Camera.CFrame = CF(Camera.CFrame.p, AimlockTarget.Character[getgenv().AimPart].Position + AimlockTarget.Character[getgenv().AimPart].Velocity/PredictionVelocity)
					elseif getgenv().PredictMovement == false then 
						Camera.CFrame = CF(Camera.CFrame.p, AimlockTarget.Character[getgenv().AimPart].Position)
					end
				end 
			end
		end
	end
	if CheckIfJumped == true then
		if L_27_.Character.Humanoid.FloorMaterial == Enum.Material.Air then
			getgenv().AimPart = "RightFoot"
		else
			getgenv().AimPart = getgenv().OldAimPart
		end
	end
end)



if getgenv().AutoPredictionAimlock == true then
	wait(5.2)
		local pingvalue = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString()
		local split = string.split(pingvalue,'(')
		local ping = tonumber(split[1])
			local PingNumber = pingValue[1]

 if  ping < 250 then
		getgenv().PredictionVelocity = 4.89
		elseif ping < 150 then
			getgenv().PredictionVelocity = 5.43
		elseif ping < 130 then
			getgenv().PredictionVelocity = 6.34
		elseif ping < 120 then
			getgenv().PredictionVelocity = 6.54
		elseif ping < 110 then
			getgenv().PredictionVelocity = 6.6
		elseif ping < 105 then
			getgenv().PredictionVelocity = 7
		elseif ping < 90 then
			getgenv().PredictionVelocity = 7
		elseif ping < 80 then
			getgenv().PredictionVelocity = 7
		elseif ping < 70 then
			getgenv().PredictionVelocity = 9
		elseif ping < 60 then
			getgenv().PredictionVelocity = 9
		elseif ping < 50 then
			getgenv().PredictionVelocity = 8.7
		elseif ping < 40 then
			getgenv().PredictionVelocity = 10.39
		end
	end





local lib = loadstring(game:HttpGet"https://raw.githubusercontent.com/lolimluke/catto-made-by-vault-credit-him/main/cool")()
lib.theme.accentcolor = Color3.fromRGB(106, 0, 245, 1)
lib.theme.accentcolor2 = Color3.fromRGB(106, 0, 245, 1)
lib.theme.fontsize = 16.9
local Window = lib:CreateWindow("cats.xyz 〡 beta", Vector2.new(492, 598), Enum.KeyCode.RightControl)local NotifyLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kinlei/Dynissimo/main/Scripts/AkaliNotif.lua"))()
local Notify = NotifyLibrary.Notify
lib.theme.font = Enum.Font.Code
local NotifyLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kinlei/Dynissimo/main/Scripts/AkaliNotif.lua"))()
local Notify = NotifyLibrary.Notify




local tab1 = Window:CreateTab("aiming")
local tab2 = Window:CreateTab("misc")
local sector1 = tab1:CreateSector("isnt it obvious","left") --aimlock
local sector9 = tab1:CreateSector("silent aim","right") --aimlock
local sector3 = tab2:CreateSector("antilock","left") 
local sector5 = tab2:CreateSector("hvh stuff","right") 








sector1:AddToggle("aimlock",false,function(dee)
    getgenv().ThirdPerson = dee 
    getgenv().FirstPerson = dee
end)






sector1:AddDropdown("hitbox",{"Head";"UpperTorso";"HumanoidRootPart", "LeftUpperLeg", "LowerTorso"},"HumanoidRootPart",false, function(mhm)
	getgenv().AimPart = mhm
	getgenv().OldAimPart = mhm
	end)
	

	sector1:AddTextbox("bind",false,function(yaas)
		getgenv().AimlockKey = yaas
	end)
		
		sector1:AddTextbox("prediction",false,function(beb)
		getgenv().PredictionVelocity = beb
		end)
        


        sector3:AddButton("anti-lock (z)", function()
			repeat
				wait()
			until game:IsLoaded()
			local yesimcool = game:service('Players')
			local imnotcool = yesimcool.LocalPlayer
			repeat
				wait()
			until imnotcool.Character
			local wtf = game:service('UserInputService')
			local meme = game:service('RunService')
			getgenv().Multiplier = 0.5
			local okay = true
			local troll
			wtf.InputBegan:connect(function(downbadarg0)
				if downbadarg0.KeyCode == Enum.KeyCode.LeftBracket then
					Multiplier = Multiplier + 0.01
					print(Multiplier)
					wait(0.2)
					while wtf:IsKeyDown(Enum.KeyCode.LeftBracket) do
						wait()
						Multiplier = Multiplier + 0.01
						print(Multiplier)
					end
				end
				if downbadarg0.KeyCode == Enum.KeyCode.RightBracket then
					Multiplier = Multiplier - 0.01
					print(Multiplier)
					wait(0.2)
					while wtf:IsKeyDown(Enum.KeyCode.RightBracket) do
						wait()
						Multiplier = Multiplier - 0.01
						print(Multiplier)
					end
				end
				if downbadarg0.KeyCode == Enum.KeyCode.Z then
					okay = not okay
					if okay == true then
						repeat
							game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame + game.Players.LocalPlayer.Character.Humanoid.MoveDirection * Multiplier
							game:GetService("RunService").Stepped:wait()
						until okay == false
					end
				end
			end)
		
		
		end)

 

        
		sector3:AddTextbox("anti-lock speed",false,function(bebe)
			getgenv().Multiplier = bebe
			end)
		
			
	sector3:AddButton("anti-lock fix", function()
		
		for _, v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
			if v:IsA("Script") and v.Name ~= "Health" and v.Name ~= "Sound" and v:FindFirstChild("LocalScript") then
				v:Destroy()
			end
		end
		game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
			repeat
				wait()
			until game.Players.LocalPlayer.Character
			char.ChildAdded:Connect(function(child)
				if child:IsA("Script") then 
					wait(0.1)
					if child:FindFirstChild("LocalScript") then
						child.LocalScript:FireServer()
					end
				end
			end)
		end)
	
	end)
	

    
	sector5:AddToggle("spinbot",false,function(state)
	

		function getRoot(char)
			local rootPart = char:FindFirstChild('HumanoidRootPart') or char:FindFirstChild('UpperTorso')
			return rootPart
		end

		if state == true then
			local Spin = Instance.new("BodyAngularVelocity")
			Spin.Name = "Spinning"
			Spin.Parent = getRoot(game.Players.LocalPlayer.Character)
			Spin.MaxTorque = Vector3.new(0, math.huge, 0)
			Spin.AngularVelocity = Vector3.new(0,getgenv().SpinBotSpeed,0)
		else
			for i,v in pairs(getRoot(game.Players.LocalPlayer.Character):GetChildren()) do
				if v.Name == "Spinning" then
					v:Destroy()
				end
			end
		end


	end)



	sector5:AddTextbox("spinbot speed",false,function(beb)
		getgenv().SpinBotSpeed = (beb)
		end)
	

			


	sector5:AddToggle("auto rotate",true,function(zenW)
	
		game.Players.LocalPlayer.Character.Humanoid.AutoRotate = zenW


	end)


    sector9:AddToggle("silent aim",false,function(fart)
	
		Aiming.Enabled = fart


	end)




    
 local feruifoiygesfo = sector9:AddToggle("show fov",false,function(fart2)
	
		Aiming.ShowFOV = fart2


	end)


    sector9:AddDropdown("aimpart",{"Head";"UpperTorso";"HumanoidRootPart", "LowerTorso"},"HumanoidRootPart",false, function(yass)
        Aiming.TargetPart = yass
        end)		

        
        sector9:AddSlider("fov radius", 0, 1, 250, 30, function(beb2)
             
            Aiming.FOV = beb2
        end)


        sector9:AddToggle("visible check",false,function(yert)
            Aiming.VisibleCheck = yert
           end)
        

           sector9:AddTextbox("hitchance",false,function(bbbb)
            Aiming.HitChance = bbbb
            end)
            

            sector9:AddTextbox("prediction",false,function(bbn)
                DaHoodSettings.Prediction = bbn
                end)
                            
      


		
    

local dqdqwdwqdqw = feruifoiygesfo:AddColorpicker(Color3.fromRGB(255, 179, 224), function(f9iuhfgiupshp9iufhpiesgfr)
Aiming.FOVColour = f9iuhfgiupshp9iufhpiesgfr
end)
