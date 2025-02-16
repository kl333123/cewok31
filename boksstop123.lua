local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Anti-AFK
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    game:GetService("VirtualUser"):CaptureController()
    game:GetService("VirtualUser"):ClickButton2(Vector2.new())
end)

local Window = Rayfield:CreateWindow({
   Name = "Qwee Hub",
   Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "Qwee Hub Loading....",
   LoadingSubtitle = "by KLPN",
   Theme = "Default", -- Check https://docs.sirius.menu/rayfield/configuration/themes

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface

   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil, -- Create a custom folder for your hub/game
      FileName = "Big Hub"
   },

   Discord = {
      Enabled = true, -- Prompt the user to join your Discord server if their executor supports it
      Invite = "pyEJhdxzPq", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ ABCD would be ABCD
      RememberJoins = true -- Set this to false to make them join the discord every time they load it up
   },

   KeySystem = false, -- Set this to true to use our key system
   KeySettings = {
      Title = "Untitled",
      Subtitle = "Key System",
      Note = "No method of obtaining the key is provided", -- Use this to tell the user how to get a key
      FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"Hello"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   }
})

-- Main
local MainTab = Window:CreateTab("🏠 Home", nil) -- Title, Image
local MainSection = MainTab:CreateSection("Main")

local player = game:GetService("Players").LocalPlayer
local humanoid = nil

-- Variables to store WalkSpeed and JumpPower values
local savedWalkSpeed = 16 -- Default walk speed value
local savedJumpPower = 50 -- Default jump power value

-- WalkSpeed Input (created only once)
local WalkSpeedInput = MainTab:CreateInput({
   Name = "WalkSpeed (Normal Speed = 16)",
   CurrentValue = tostring(savedWalkSpeed), -- Set initial value to savedWalkSpeed
   PlaceholderText = "Enter Speed",
   RemoveTextAfterFocusLost = false,
   Flag = "input_ws",
   Callback = function(Text)
       local Value = tonumber(Text)
       if humanoid and Value then
           savedWalkSpeed = math.clamp(Value, 1, 350) -- Save the new value
           humanoid.WalkSpeed = savedWalkSpeed -- Apply the value
       end
   end,
})

-- JumpPower Input (created only once)
local JumpPowerInput = MainTab:CreateInput({
   Name = "JumpPower (Normal Jump = 50)",
   CurrentValue = tostring(savedJumpPower), -- Set initial value to savedJumpPower
   PlaceholderText = "Enter Power",
   RemoveTextAfterFocusLost = false,
   Flag = "input_jp",
   Callback = function(Text)
       local Value = tonumber(Text)
       if humanoid and Value then
           savedJumpPower = math.clamp(Value, 1, 350) -- Save the new value
           humanoid.JumpPower = savedJumpPower -- Apply the value
       end
   end,
})

-- Function to reset humanoid and inputs when respawning
local function onCharacterAdded(character)
    humanoid = character:WaitForChild("Humanoid")

    -- Apply saved WalkSpeed and JumpPower to the new character's humanoid
    humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        humanoid.WalkSpeed = savedWalkSpeed
    end)
    humanoid:GetPropertyChangedSignal("JumpPower"):Connect(function()
        humanoid.JumpPower = savedJumpPower
    end)

    -- Ensure the values are set immediately
    humanoid.WalkSpeed = savedWalkSpeed
    humanoid.JumpPower = savedJumpPower

    -- Update the input boxes with the saved values
    WalkSpeedInput:Set(tostring(savedWalkSpeed))
    JumpPowerInput:Set(tostring(savedJumpPower))
end

-- Rebind humanoid and inputs when character respawns
player.CharacterAdded:Connect(onCharacterAdded)

-- Initialize for the first time in case the character is already in the game
if player.Character then
    onCharacterAdded(player.Character)
end

--Infinity Jump

local localPlayer = game:GetService("Players").LocalPlayer
local userInputService = game:GetService("UserInputService")
local infiniteJumpEnabled = false

local Toggle = MainTab:CreateToggle({
   Name = "Infinite Jump",
   CurrentValue = false,
   Flag = "infinite_jump_flag",
   Callback = function(Value)
        infiniteJumpEnabled = Value

        if infiniteJumpEnabled then
            -- Powiadomienie o aktywacji
            game.StarterGui:SetCore("SendNotification", {
                Title = "Qwee Hub",
                Text = "Infinite Jump Activated!",
                Duration = 5
            })
        end
   end
})

-- Obsługa skoku
userInputService.JumpRequest:Connect(function()
    if infiniteJumpEnabled and localPlayer.Character then
        local humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)


-- Noclip

local RunService = game:GetService("RunService")
local localPlayer = game:GetService("Players").LocalPlayer
local noclipLoop

local Toggle = MainTab:CreateToggle({
   Name = "Noclip",
   CurrentValue = false,
   Flag = "klpn444",
   Callback = function(Value)
        if Value then
            -- Włączanie Noclip
            noclipLoop = RunService.Stepped:Connect(function()
                if localPlayer.Character then
                    for _, part in pairs(localPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        else
            -- Natychmiastowe wyłączenie Noclip
            if noclipLoop then 
                noclipLoop:Disconnect()
                noclipLoop = nil
            end
            
            -- Przywrócenie kolizji od razu po wyłączeniu
            if localPlayer.Character then
                for _, part in pairs(localPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end
   end
})

--Fly------------------------------------------------------------------------------------------------------------------
local localPlayer = game:GetService("Players").LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local flyEnabled = false
local flySpeed = 50
local FLY_SPEED_MULTIPLIER = 2
local activeKeys = {}
local bodyVelocity
local bodyGyro
local flyConnection

-- Klawisze sterowania lotem
local flyKeys = {
    Forward = Enum.KeyCode.S,
    Backward = Enum.KeyCode.W,
    Left = Enum.KeyCode.A,
    Right = Enum.KeyCode.D,
    Up = Enum.KeyCode.Space,
    Down = Enum.KeyCode.LeftShift
}

local function getHumanoid()
    return localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
end

local function toggleFly()
    flyEnabled = not flyEnabled

    if flyEnabled then
        -- Włączenie lotu
        local humanoid = getHumanoid()
        local rootPart = humanoid and humanoid.RootPart

        if humanoid and rootPart then
            humanoid.PlatformStand = true
            
            -- Tworzenie obiektów fizyki
            bodyGyro = Instance.new("BodyGyro")
            bodyGyro.P = 10000
            bodyGyro.D = 100
            bodyGyro.MaxTorque = Vector3.new(20000, 20000, 20000)
            bodyGyro.CFrame = rootPart.CFrame
            bodyGyro.Parent = rootPart
            
            bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.Velocity = Vector3.new()
            bodyVelocity.MaxForce = Vector3.new(10000, 10000, 10000)
            bodyVelocity.Parent = rootPart
            
            -- Start lotu
            flyConnection = RunService.Heartbeat:Connect(function()
                if not flyEnabled or not bodyVelocity or not bodyGyro then return end
                
                local currentSpeed = flySpeed
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                    currentSpeed = flySpeed * FLY_SPEED_MULTIPLIER
                end
                
                -- Kierunek lotu
                local camera = workspace.CurrentCamera
                local cameraCFrame = camera.CFrame
                local direction = Vector3.new()

                if activeKeys[flyKeys.Forward] then direction -= cameraCFrame.LookVector end
                if activeKeys[flyKeys.Backward] then direction += cameraCFrame.LookVector end
                if activeKeys[flyKeys.Left] then direction -= cameraCFrame.RightVector end
                if activeKeys[flyKeys.Right] then direction += cameraCFrame.RightVector end
                if activeKeys[flyKeys.Up] then direction += cameraCFrame.UpVector end
                if activeKeys[flyKeys.Down] then direction -= cameraCFrame.UpVector end

                if direction.Magnitude > 0 then
                    bodyVelocity.Velocity = direction.Unit * currentSpeed
                else
                    bodyVelocity.Velocity = Vector3.new()
                end

                bodyGyro.CFrame = cameraCFrame
            end)
        end
    else
        -- Wyłączenie lotu
        if bodyVelocity then bodyVelocity:Destroy() end
        if bodyGyro then bodyGyro:Destroy() end
        if flyConnection then flyConnection:Disconnect() end
        
        local humanoid = getHumanoid()
        if humanoid then
            humanoid.PlatformStand = false
        end
    end
end

-- Obsługa klawiszy
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if flyEnabled and not gameProcessed then
        activeKeys[input.KeyCode] = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if flyEnabled then
        activeKeys[input.KeyCode] = nil
    end
end)

-- Tworzenie Toggle dla Fly
local flyToggle = MainTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Flag = "fly_toggle",
    Callback = function(Value)
        toggleFly()
    end
})


---------------------------------------------------Auto Farm-----------------------------------------------------------------------------------------------------------
local AutoTab = Window:CreateTab("👩🏻‍🌾Auto Farm", nil)
local AutoSection = AutoTab:CreateSection("Main")

local player = game:GetService("Players").LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
local autoFarmEnabled = false  -- To control the auto-farming loop

local teleportLocations = {
    Vector3.new(-41.406883239746094, 65.15724182128906, -532.2268676757812),
    Vector3.new(763.8363037109375, 125.14930725097656, -1320.6099853515625),
    Vector3.new(-455.3819580078125, 24.766002655029297, 530.1331176757812),
     Vector3.new(-959.9144897460938, 150.3213653564453, -1058.79443359375),
    Vector3.new(1177.5816650390625, 29.10352897644043, 1044.92333984375),
    Vector3.new(-1129.84423828125, 55.12990951538086, 1423.623779296875)
}

-- Lista ore'ów (modele zbierane w grze)
local oreNames = {
    "Crystal Rock", "Gold Rock", "Ice1", "Turquoise Rock", 
    "Topaz Rock", "Titanium Rock", "Green Quartz Rock", "Coal Rock", 
    "Amethyst Rock", "Apatite Rock", "Iron Rock", "Jade Rock", 
    "Rhodonite Rock", "Ruby Rock", "Sapphire Rock", "Tanzanite Rock",
    "Hiddenite Rock", "Olivine Rock", "Sodalite Rock",
}

local currentTeleportIndex = 1

-- Lista kilofów uporządkowana od najlepszego do najgorszego  
local toolPriority = {
    "Spinel Pick", "Sodalite Pick", "Serpentine Pick", "Olivine Pick",
    "Hiddenite Pick", "Fire Opal Pick", "Obsidian Pick", "Jade Pick",
    "Titanium Pick", "Topaz Pick", "Ruby Pick", "Shell Pick", "Apatite Pick",
    "Tanzanite Pick", "Sapphire Pick", "Green Quartz Pick", "Meteorite Pick",
    "Rhodonite Pick", "Crystal Pick", "Gold Pick", "Iron Pick", "Amethyst Pick",
    "Turquoise Pick", "Stone Pick", "Ice Pick", "Wood Pick"
}
local totalTools = #toolPriority  -- Całkowita liczba narzędzi

-- Funkcja wyszukiwania najlepszego dostępnego kilofa
local function findBestTool()
    for index, toolName in ipairs(toolPriority) do
        local tool = player.Backpack:FindFirstChild(toolName)
        if tool then
            return tool, index
        end
    end
    if player.Character then
        for index, toolName in ipairs(toolPriority) do
            local tool = player.Character:FindFirstChild(toolName)
            if tool then
                return tool, index
            end
        end
    end
    return nil, nil
end

local function freezeCharacter()
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, hrp.Orientation.Y, 0)
    end
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Anchored = true
        end
    end
end

-- Funkcja odmrażająca postać
local function unfreezeCharacter()
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Anchored = false
        end
    end
end

-- Funkcja ataku ore
local function attackOre(ore)
    if ore and ore:GetAttribute("Health") then
        local tool, toolIndex = findBestTool()
        if not tool then
            return  -- Jeśli brak narzędzia, przerywamy atak
        end

        local damageIndex = totalTools - toolIndex + 1
        local damage = 10 + (damageIndex - 1) * 5

        if tool.Parent == player.Backpack then
            player.Character.Humanoid:EquipTool(tool)
            wait(0.5)
        end

        local rootPart = player.Character.HumanoidRootPart
        local orePosition = ore.PrimaryPart and ore.PrimaryPart.Position or ore:GetPivot().Position
        rootPart.CFrame = CFrame.new(orePosition + Vector3.new(0, 5, 0))
        wait(0.5)

        freezeCharacter()

        while autoFarmEnabled and ore:GetAttribute("Health") > 0 do
            local distance = (rootPart.Position - orePosition).Magnitude
            if distance <= 10 then
                local currentHealth = ore:GetAttribute("Health")
                tool:Activate()
                ore:SetAttribute("Health", currentHealth - damage)
                wait(1)
            else
                break  
            end
        end

        unfreezeCharacter()

        if ore:GetAttribute("Health") <= 0 then
            ore:Destroy()
        end
    end
end

-- Funkcja do znajdowania najbliższego ore
local function findNearestOre()
    local nearestOre = nil
    local nearestDistance = math.huge
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and table.find(oreNames, obj.Name) then
            local orePosition = obj.PrimaryPart and obj.PrimaryPart.Position or obj:GetPivot().Position
            local distance = (humanoidRootPart.Position - orePosition).Magnitude
            if distance < nearestDistance then
                nearestOre = obj
                nearestDistance = distance
            end
        end
    end
    return nearestOre
end

local function autoFarm()
    while autoFarmEnabled do
        local nearestOre = findNearestOre()
        if nearestOre then
            humanoidRootPart.CFrame = nearestOre.PrimaryPart and nearestOre.PrimaryPart.CFrame or nearestOre:GetPivot()
            wait(0.3)
            attackOre(nearestOre)
        else
            currentTeleportIndex = currentTeleportIndex % #teleportLocations + 1
            humanoidRootPart.CFrame = CFrame.new(teleportLocations[currentTeleportIndex])
            wait(1)
        end
    end
end

if AutoTab and AutoTab.CreateToggle then
    local AutoFarmOreToggle = AutoTab:CreateToggle({
        Name = "Auto Farm Ore",
        CurrentValue = autoFarmEnabled,
        Flag = "AutoFarm_toggled",
        Callback = function(value)
            autoFarmEnabled = value
            if autoFarmEnabled then
                autoFarm()
            end
        end
    })
end


-----------------------------Auto Pick Up----------------------------------------------------------------------------------------------

local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local runService = game:GetService("RunService")

local PICKUP_RANGE = 10
local AUTO_PICKUP_ENABLED = false

-- Pełna lista rud bez "Rock" i "Ore"
local ALL_ORES = {
    "All", "Stone", "Crystal", "Gold", "Ice", "Turquoise", "Topaz", "Titanium", "Green Quartz", "Coal",
    "Amethyst", "Apatite", "Iron", "Jade", "Rhodonite", "Ruby", "Sapphire", "Tanzanite",
    "Hiddenite", "Olivine", "Sodalite", "Serpentine", "Spinel", "Fire Opal", "Obsidian", "Meteorite"
}

local ALLOWED_ORES = {} -- Domyślnie nic nie zbiera

-- Funkcja sprawdzająca, które przedmioty można podnieść
local function findPickableItems()
    local items = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if (obj:IsA("MeshPart") or obj:IsA("UnionOperation")) and obj:FindFirstChildOfClass("ProximityPrompt") then
            local oreName = obj.Name:gsub(" Rock", ""):gsub(" Ore", "") -- Usuwanie "Rock" i "Ore"
            if ALLOWED_ORES["All"] or ALLOWED_ORES[oreName] then
                table.insert(items, obj)
            end
        end
    end
    return items
end

-- Funkcja aktywująca ProximityPrompt
local function activateProximityPrompt(prompt)
    if prompt.Enabled then
        prompt.HoldDuration = 0
        prompt:InputHoldBegin()
        prompt:InputHoldEnd()
    end
end

-- Główna pętla zbierania przedmiotów
local lastCheck = 0
runService.Heartbeat:Connect(function(dt)
    if not AUTO_PICKUP_ENABLED then return end

    lastCheck += dt
    if lastCheck < 0.1 then return end -- Ograniczenie do 10 razy na sekundę
    lastCheck = 0

    local character = player.Character
    local humanoidRoot = character and character:FindFirstChild("HumanoidRootPart")
    if not humanoidRoot then return end

    for _, item in ipairs(findPickableItems()) do
        if (item.Position - humanoidRoot.Position).Magnitude <= PICKUP_RANGE then
            local prompt = item:FindFirstChildOfClass("ProximityPrompt")
            if prompt then
                activateProximityPrompt(prompt)
            end
        end
    end
end)

-- Przycisk do włączania/wyłączania auto-pickupu
if AutoTab and AutoTab.CreateToggle then
    AutoTab:CreateToggle({
        Name = "Auto Pick Up Ores",
        CurrentValue = AUTO_PICKUP_ENABLED,
        Flag = "AutoPickupToggle",
        Callback = function(value)
            AUTO_PICKUP_ENABLED = value
        end
    })
end

-- Dropdown do wyboru zbieranych przedmiotów
local Dropdown = AutoTab:CreateDropdown({
    Name = "Select Ores",
    Options = ALL_ORES,
    CurrentOption = {}, -- Domyślnie nic nie jest zaznaczone
    MultipleOptions = true, -- Można zaznaczyć wiele opcji
    Flag = "OreSelection",
    Callback = function(selectedOptions)
        -- Aktualizacja listy zbieranych przedmiotów
        ALLOWED_ORES = {}

        if #selectedOptions == 0 then
            -- Jeśli nic nie wybrano, nic nie zbieraj
            return
        end

        if table.find(selectedOptions, "All") then
            -- Jeśli wybrano "All", zbieraj wszystko
            ALLOWED_ORES["All"] = true
        else
            -- W przeciwnym razie, zbieraj tylko wybrane
            for _, ore in ipairs(selectedOptions) do
                ALLOWED_ORES[ore] = true
            end
        end
    end,
})

----piciu

local Tab = {} -- Assuming you have a Tab object or table to create UI elements

-- Variables to control the auto-pickup loop and store the player's original position
local autoPickupEnabled = false
local originalPosition = nil

-- Create the toggle
local Toggle = AutoTab:CreateToggle({
   Name = "Get Water",
   CurrentValue = false,
   Flag = "Toggle1", -- Unique identifier for the configuration file
   Callback = function(Value)
       autoPickupEnabled = Value -- Update the state of the auto-pickup loop

       if autoPickupEnabled then
           -- Teleport the player to the item's position
           local player = game.Players.LocalPlayer
           local character = player.Character
           if character and character:FindFirstChild("HumanoidRootPart") then
               -- Store the player's original position
               originalPosition = character.HumanoidRootPart.CFrame

               -- Teleport to the item's position
               character.HumanoidRootPart.CFrame = CFrame.new(78.67840576171875, 60.04999923706055, -369.82208251953125)
           end

           -- Start the auto-pickup loop
           while autoPickupEnabled do
               -- Define the arguments for the Pickup event
               local args = {
                   [1] = "Water", -- Replace with the correct item name
                   [2] = Vector3.new(78.67840576171875, 60.04999923706055, -369.82208251953125) -- Replace with the correct position
               }

               -- Get the RemoteEvent
               local Events = game:GetService("ReplicatedStorage"):WaitForChild("Events")
               local PickupEvent = Events:WaitForChild("Pickup")

               -- Fire the event
               PickupEvent:FireServer(table.unpack(args))

               -- Add a small delay to avoid spamming the server
               wait(0.03)
           end
       else
           -- Teleport the player back to their original position
           if originalPosition then
               local player = game.Players.LocalPlayer
               local character = player.Character
               if character and character:FindFirstChild("HumanoidRootPart") then
                   character.HumanoidRootPart.CFrame = originalPosition
               end
           end
       end
   end,
})

--------------------------bread


-- Define the autoBuy function
local function autoBuy()
    local args = {
        [1] = workspace:WaitForChild("Village"):WaitForChild("Bakery"):WaitForChild("Main"):WaitForChild("Interaction"):WaitForChild("BuildingInput"),
        [2] = "Bread",  -- Item to be bought
        [3] = "Bakery"  -- Building where the item is available
    }
    
    -- Fire the event to buy the item
    game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("TellBuilding"):FireServer(unpack(args))
end

-- Function to teleport the player to the specified coordinates
local function teleportToCoordinates()
    local player = game.Players.LocalPlayer
    
    -- Use the provided coordinates (827.1376342773438, 65.95413208007812, -408.6312255859375)
    local teleportPosition = Vector3.new(827.1376342773438, 65.95413208007812, -408.6312255859375)
    
    -- Teleport the player to the new position
    player.Character:SetPrimaryPartCFrame(CFrame.new(teleportPosition))
end

-- Function to teleport the player back to their original position
local function teleportBackToOriginalPosition(originalPosition)
    local player = game.Players.LocalPlayer
    
    -- Teleport the player back to the original position
    player.Character:SetPrimaryPartCFrame(CFrame.new(originalPosition))
end

-- Variable to store the player's original position
local originalPosition = nil

-- Create the toggle
local Toggle = AutoTab:CreateToggle({
    Name = "Get Bread ( Cost 20 Coins Each)",
    CurrentValue = false,
    Flag = "Toggle1", -- Unique identifier for the configuration file
    Callback = function(Value)
        autoPickupEnabled = Value -- Update the state of the auto-pickup loop
        
        -- Store the player's original position before teleporting (only if it's not already stored)
        local player = game.Players.LocalPlayer
        if not originalPosition then
            originalPosition = player.Character.PrimaryPart.Position
        end
        
        if autoPickupEnabled then
            -- First teleport to the specified coordinates
            teleportToCoordinates()
            
            -- Start auto-buying loop if the toggle is on
            while autoPickupEnabled do
                autoBuy()  -- Trigger the auto-buy function
                wait(0.3)  -- Add the delay of 0.3 seconds
            end
        else
            -- When the toggle is off, teleport the player back to the original position
            teleportBackToOriginalPosition(originalPosition)
        end
    end
})


----auto consumes

local Player = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Events = ReplicatedStorage:WaitForChild("Events")

local Vitals = Player:WaitForChild("PlayerData"):WaitForChild("Vitals")
local Consume = Events:WaitForChild("Consume")

local Toggle = AutoTab:CreateToggle({
   Name = "Auto Consumes (Requires Bread and Water)",
   CurrentValue = false,
   Flag = "Toggle1",
   Callback = function(Value)
      Toggle.CurrentValue = Value -- Update the toggle's current value
   end,
})

Vitals:WaitForChild("Hunger").Changed:Connect(function()
    if Toggle.CurrentValue and Vitals.Hunger.Value <= 60 then
        spawn(function()
            repeat
                Consume:FireServer("Bread")
                task.wait(0.5)
            until Vitals.Hunger.Value >= 100
        end)
    end
end)

Vitals:WaitForChild("Thirst").Changed:Connect(function()
    if Toggle.CurrentValue and Vitals.Thirst.Value <= 70 then
        spawn(function()
            repeat
                Consume:FireServer("Water")
                task.wait(0.5)
            until Vitals.Thirst.Value >= 100
        end)
    end
end)


-------------------------------auto sell all

local AutoTab = Window:CreateTab("💰 Auto Sell", nil) -- Create a new tab for Auto Sell
local AutoSellSection = AutoTab:CreateSection("Auto Sell Settings")

local autoSellEnabled = false
local sellInterval = 1 -- Time in seconds between each sell attempt
local itemsToSell = {} -- Start with no items selected

-- List of all sellable items
local allItems = {"Stone", "Iron", "Ice", "Gold", "Amethyst", "Apatite", "Coal", "Crystal", "Fire Opal", "Green Quartz", "Hiddenite", "Jade", "Meteorite", "Obsidian", "Pearl", "Rhodonite", "Ruby", "Sapphire", "Tanzanite", "Titanium", "Topaz", "Turquoise"}

-- List of hidden items to auto-sell (not shown in the dropdown)
local hiddenItemsToSell = {"Pumpkin", "Burned Log", "Strawberry", "Raw Meat", "Blueberry", "Banana", "Apple", "Cranberry", "Wheat"} -- Add any items you want to auto-sell but not show in the dropdown

-- Function to sell items
local function sellItems()
    -- Sell items selected in the dropdown
    for _, itemName in pairs(itemsToSell) do
        local args = {
            [1] = itemName, -- Item name
            [2] = 1 -- Quantity (you can adjust this if needed)
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Market"):FireServer(unpack(args))
    end

    -- Sell hidden items (not shown in the dropdown)
    for _, itemName in pairs(hiddenItemsToSell) do
        local args = {
            [1] = itemName, -- Item name
            [2] = 1 -- Quantity (you can adjust this if needed)
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Market"):FireServer(unpack(args))
    end
end

-- Main auto-sell loop
local function autoSellLoop()
    while autoSellEnabled do
        sellItems() -- Sell items
        wait(sellInterval) -- Wait for the specified interval
    end
end

-- Toggle for Auto Sell
local Toggle = AutoTab:CreateToggle({
    Name = "Enable Auto Sell",
    CurrentValue = false,
    Flag = "AutoSellToggle",
    Callback = function(value)
        autoSellEnabled = value
        if autoSellEnabled then
            autoSellLoop() -- Start the auto-sell loop
        end
    end
})

-- Dropdown to select items to sell
local Dropdown = AutoTab:CreateDropdown({
    Name = "Select Items to Sell",
    Options = {"All", "Stone", "Iron", "Gold", "Ice", "Amethyst", "Apatite", "Coal", "Crystal", "Fire Opal", "Green Quartz", "Hiddenite", "Jade", "Meteorite", "Obsidian", "Pearl", "Rhodonite", "Ruby", "Sapphire", "Tanzanite", "Titanium", "Topaz", "Turquoise"}, -- Add all sellable items here
    CurrentOption = {}, -- Start with no items selected
    MultipleOptions = true,
    Flag = "AutoSellItemsDropdown",
    Callback = function(selected)
        if table.find(selected, "All") then
            itemsToSell = allItems -- Select all items if "All" is chosen
        else
            itemsToSell = selected -- Update the list of items to sell
        end
    end
})

-- Input for sell interval
local Input = AutoTab:CreateInput({
    Name = "Sell Interval (Seconds)",
    CurrentValue = tostring(sellInterval),
    PlaceholderText = "Enter Interval",
    RemoveTextAfterFocusLost = false,
    Flag = "AutoSellIntervalInput",
    Callback = function(Text)
        local value = tonumber(Text)
        if value then
            sellInterval = math.max(1, value) -- Ensure the interval is at least 1 second
        end
    end
})

--------------------------------------------------------------------------------------------PLayer auto---------------------------------------------------------------

local PlayerTab = Window:CreateTab("🤖 Player", nil) -- Title, Image
local PlayerSection = PlayerTab:CreateSection("Main")



-----------------------------------------ESp--------------------------------

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local ESPObjects = {}
local ESP_DISTANCE = 1000 -- Maximum ESP distance

-- Create a single ScreenGui for all Highlights
local espScreenGui = Instance.new("ScreenGui")
espScreenGui.Name = "ESPGui"
espScreenGui.Parent = game:GetService("CoreGui")

-- Function to create Wallhack (Highlight)
local function CreateWallhack(player)
    if player == LocalPlayer or ESPObjects[player] then return end

    local highlight = Instance.new("Highlight")
    highlight.Parent = espScreenGui
    highlight.FillColor = Color3.fromRGB(0, 255, 0) -- Green fill
    highlight.OutlineColor = Color3.fromRGB(0, 0, 0) -- Black outline
    highlight.FillTransparency = 0.3 -- Slightly transparent
    highlight.OutlineTransparency = 0 -- Solid outline

    -- Store the highlight and its connection
    ESPObjects[player] = {
        Highlight = highlight,
        RenderConnection = RunService.RenderStepped:Connect(function()
            highlight.Adornee = player.Character and player.Character.PrimaryPart or nil
        end)
    }
end

-- Function to create ESP (NameTag) with rainbow effect
local function CreateESP(player)
    if player == LocalPlayer or not ESPObjects[player] then return end

    local nameTag = Drawing.new("Text")
    nameTag.Size = 18
    nameTag.Center = true
    nameTag.Outline = true
    nameTag.OutlineColor = Color3.fromRGB(0, 0, 0) -- Black outline
    nameTag.Font = Drawing.Fonts.UI -- Modern font
    nameTag.Visible = false

    -- Store the NameTag and its connection
    ESPObjects[player].NameTag = nameTag
    ESPObjects[player].ESPConnection = RunService.RenderStepped:Connect(function()
        if not player.Character then
            nameTag.Visible = false
            return
        end

        local head = player.Character:FindFirstChild("Head")
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        local localRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

        if head and humanoid and localRoot then
            local distance = (head.Position - localRoot.Position).Magnitude
            if distance <= ESP_DISTANCE then
                local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(head.Position + Vector3.new(0, 2.5, 0))
                if onScreen then
                    -- Rainbow color effect
                    local hue = tick() % 5 / 5 -- Cycle through colors over time
                    local rainbowColor = Color3.fromHSV(hue, 1, 1)

                    -- Update NameTag properties
                    nameTag.Position = Vector2.new(pos.X, pos.Y)
                    nameTag.Text = string.format("[%s] [%d HP] (%dm)", player.Name, humanoid.Health, distance)
                    nameTag.Color = rainbowColor
                    nameTag.Visible = true
                    return
                end
            end
        end
        nameTag.Visible = false
    end)
end

-- Function to enable ESP for all players
local function EnableESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            CreateWallhack(player)
            CreateESP(player)
        end
    end
end

-- Function to disable ESP for a specific player
local function DisableESP(player)
    if ESPObjects[player] then
        ESPObjects[player].Highlight:Destroy()
        if ESPObjects[player].NameTag then
            ESPObjects[player].NameTag:Remove()
        end
        ESPObjects[player].RenderConnection:Disconnect()
        if ESPObjects[player].ESPConnection then
            ESPObjects[player].ESPConnection:Disconnect()
        end
        ESPObjects[player] = nil
    end
end

-- Toggle logic
local Toggle = PlayerTab:CreateToggle({
    Name = "Enable PLAYER ESP", 
    CurrentValue = false,  -- Initially off
    Flag = "PlayerESP", 
    Callback = function(Value)
        if Value then
            EnableESP()  -- Enable ESP when toggle is on
        else
            for player, _ in pairs(ESPObjects) do
                DisableESP(player)  -- Disable ESP for each player when toggle is off
            end
        end
    end,
})

-- Handle new players joining
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        if Toggle.CurrentValue then  -- Only enable ESP if the toggle is on
            CreateWallhack(player)
            CreateESP(player)
        end
    end)
end)

-- Handle players leaving
Players.PlayerRemoving:Connect(function(player)
    if ESPObjects[player] then
        DisableESP(player)  -- Clean up ESP for the player who left
    end
end)



---------espORESS

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

local ESPObjects = {}
local SelectedOres = {}

-- Function to get ores from Workspace
local function GetGroupedOres()
    return {
        "Crystal Rock", "Gold Rock", "Turquoise Rock", "Topaz Rock", "Titanium Rock", 
        "Green Quartz Rock", "Coal Rock", "Amethyst Rock", "Apatite Rock", "Iron Rock", 
        "Jade Rock", "Rhodonite Rock", "Ruby Rock", "Sapphire Rock", "Tanzanite Rock",
        "Hiddenite Rock", "Olivine Rock", "Serpentine Rock", "Spinel Rock", "Sodalite Rock"
    }
end

-- Function to create ESP and Nametag
local function CreateESP(ore)
    if ESPObjects[ore] then return end

    -- Create the Highlight with purple color
    local highlight = Instance.new("Highlight")
    highlight.Adornee = ore
    highlight.Parent = ore
    highlight.FillColor = Color3.fromRGB(128, 0, 128)  -- Purple color
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255) -- White outline
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

    -- Create the Nametag
    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = ore
    billboard.Parent = ore
    billboard.Size = UDim2.new(0, 100, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)  -- Position the nametag above the ore
    billboard.AlwaysOnTop = true

    local label = Instance.new("TextLabel")
    label.Parent = billboard
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = ore.Name
    label.TextColor3 = Color3.fromRGB(255, 255, 255)  -- White text for the name
    label.TextSize = 14
    label.BackgroundTransparency = 1
    label.TextStrokeTransparency = 0.8

    -- Add the wallhack effect by setting Transparency for every ore
    for _, part in pairs(ore:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 0.5  -- Make the ore semi-transparent to see through walls
            part.CanCollide = false  -- Disable collisions to avoid interaction issues
            part.Reflectance = 0.1  -- Optional: Add slight reflectance for better visibility
        end
    end

    -- Store the ESP objects for cleanup
    ESPObjects[ore] = {
        highlight = highlight,
        billboard = billboard,
        label = label
    }
end

-- Function to update meters/distance in nametag
local function UpdateDistance()
    for ore, objects in pairs(ESPObjects) do
        if ore and ore.PrimaryPart and objects.label then
            local distance = (LocalPlayer.Character.HumanoidRootPart.Position - ore.PrimaryPart.Position).Magnitude
            objects.label.Text = ore.Name .. " - " .. math.floor(distance) .. "m"
        end
    end
end

-- Enable ESP for selected ores
local function EnableOreESP()
    -- Iterate through all ores in Workspace.Ores
    for _, ore in pairs(Workspace.Ores:GetChildren()) do
        if ore:IsA("Model") and table.find(SelectedOres, ore.Name) then
            CreateESP(ore)  -- Create ESP for selected ores
        end
    end

    -- Listen for new ores being added
    local connection
    connection = Workspace.Ores.ChildAdded:Connect(function(child)
        if child:IsA("Model") and table.find(SelectedOres, child.Name) then
            CreateESP(child)  -- Add ESP for newly added ores
        end
    end)

    -- Store the connection for cleanup
    ESPObjects.Connection = connection
end

-- Disable ESP
local function DisableOreESP()
    -- Disconnect the ChildAdded event
    if ESPObjects.Connection then
        ESPObjects.Connection:Disconnect()
        ESPObjects.Connection = nil
    end

    -- Destroy all highlights and nametags
    for ore, objects in pairs(ESPObjects) do
        if objects.highlight then
            objects.highlight:Destroy()
        end
        if objects.billboard then
            objects.billboard:Destroy()
        end
    end
    ESPObjects = {}
end

-- Update ESP when ore selection changes
local function UpdateOreESP()
    DisableOreESP()
    EnableOreESP()
end

-- Create the Toggle to Enable/Disable Ore ESP
local Toggle = PlayerTab:CreateToggle({
    Name = "Enable Ores ESP",
    CurrentValue = false,
    Flag = "OreESP",
    Callback = function(Value)
        if Value then
            EnableOreESP()
        else
            DisableOreESP()
        end
    end,
})

-- Create Dropdown to Select Ore Types
local Dropdown = PlayerTab:CreateDropdown({
    Name = "Choose Ores",
    Options = GetGroupedOres(),  -- Get ores to display
    CurrentOption = {} ,
    MultipleOptions = true,
    Flag = "OreDropdown",
    Callback = function(Options)
        SelectedOres = Options  -- Set selected ores
        UpdateOreESP()  -- Update ESP when selection changes
    end,
})

-- Periodically update the meters distance
task.spawn(function()
    while true do
        task.wait(0.1)  -- Update every second
        UpdateDistance()
    end
end)




-------------------------------------------------------------------------------------Teleport-----------------------------------------------------------------------


local TeleportTab = Window:CreateTab("👽 Teleport", nil) -- Title, Image
local TeleportSection = TeleportTab:CreateSection("Main")


-------------------------------------------------------Teleport to PLayer----------------------------------------------------------------

-- Reference to the Players service
local playersFolder = game:GetService("Players")
local localPlayer = playersFolder.LocalPlayer

-- Toggle for enabling/disabling teleportation
local TELEPORT_ENABLED = false
TeleportTab:CreateToggle({
    Name = "Enable Teleport",
    CurrentValue = TELEPORT_ENABLED,
    Flag = "Teleport_Toggle",
    Callback = function(value)
        TELEPORT_ENABLED = value
    end
})

-- Function to get all player names (excluding local player)
local function getPlayerNames()
    local playerNames = {}
    for _, player in ipairs(playersFolder:GetPlayers()) do
        if player ~= localPlayer then
            table.insert(playerNames, player.Name)
        end
    end
    return playerNames
end

-- Variable to store the dropdown instance
local playerDropdown = nil

-- Variable to track if the dropdown selection is being updated programmatically
local isProgrammaticUpdate = false

-- Function to create or update the dropdown
local function updateDropdown()
    local playerNames = getPlayerNames()

    -- If dropdown already exists, refresh and update its options
    if playerDropdown then
        -- Set flag to indicate programmatic update
        isProgrammaticUpdate = true

        -- Refresh options only if there is a change in the player list
        local currentOption = playerDropdown.CurrentOption
        if currentOption and not table.find(playerNames, currentOption) then
            currentOption = playerNames[1]  -- Default to first player if the previous selection is no longer valid
        end

        playerDropdown:Refresh(playerNames)  -- Update the options list
        playerDropdown:Set({currentOption or playerNames[1]})  -- Update the selected option

        -- Reset flag after programmatic update
        isProgrammaticUpdate = false
    else
        -- Create a new dropdown if it doesn't exist
        playerDropdown = TeleportTab:CreateDropdown({
            Name = "Select Player",
            Options = playerNames,
            CurrentOption = #playerNames > 0 and playerNames[1] or "",
            Flag = "Teleport_Dropdown",
            Callback = function(selected)
                -- Skip teleportation if the update is programmatic
                if isProgrammaticUpdate then
                    return
                end

                -- Handle manual selection
                local selectedName = type(selected) == "table" and selected[1] or selected

                -- Validate selected player
                local selectedPlayer = playersFolder:FindFirstChild(selectedName)
                if not selectedPlayer then
                    return
                end

                -- Validate teleportation conditions
                if TELEPORT_ENABLED then
                    local targetChar = selectedPlayer.Character
                    if not targetChar then
                        return
                    end

                    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                    if not targetRoot then
                        return
                    end

                    local localChar = localPlayer.Character
                    if not localChar then
                        return
                    end

                    local localRoot = localChar:FindFirstChild("HumanoidRootPart")
                    if not localRoot then
                        return
                    end

                    -- Perform teleportation
                    localRoot.CFrame = targetRoot.CFrame
                end
            end
        })
    end
end

-- Create the dropdown initially
updateDropdown()

-- Update dropdown when players join/leave, but don't trigger teleportation
local lastPlayerCount = #getPlayerNames()

playersFolder.PlayerAdded:Connect(function(player)
    local currentPlayerCount = #getPlayerNames()
    if currentPlayerCount > lastPlayerCount then
        updateDropdown()  -- Recreate or refresh dropdown with updated player list
        lastPlayerCount = currentPlayerCount
    end
end)

playersFolder.PlayerRemoving:Connect(function(player)
    local currentPlayerCount = #getPlayerNames()
    if currentPlayerCount < lastPlayerCount then
        updateDropdown()  -- Recreate or refresh dropdown with updated player list
        lastPlayerCount = currentPlayerCount
    end
end)



local teleportLocations = {
    ["Volcano"] = Vector3.new(729, 13, 668),
    ["Waterfall"] = Vector3.new(102, 21, 584),
    ["Apatite Area"] = Vector3.new(-466, -110, 205),
    ["Serpentine Area"] = Vector3.new(-167, -231, 1060),
    ["Spinel Area"] = Vector3.new(-1402, -272, 502),
    ["Pixies Area"] = Vector3.new(111.1286, 65.0869, -43.4186),
    ["Village"] = Vector3.new(733.3862, 64.9541, -372.0994)
}


local Dropdown = TeleportTab:CreateDropdown({
    Name = "Teleport Locations",
    Options = {"Volcano", "Waterfall", "Apatite Area", "Serpentine Area", "Spinel Area","Pixies Area", "Village"},
    CurrentOption = {"Volcano"},
    MultipleOptions = false,
    Flag = "TeleportDropdown",
    Callback = function(Options)
        if player and player.Character then
            local humRoot = player.Character:FindFirstChild("HumanoidRootPart")
            if humRoot and teleportLocations[Options[1]] then
                humRoot.CFrame = CFrame.new(teleportLocations[Options[1]] + Vector3.new(0, 4, 0))
            end
        end
    end
})

local UIS = game:GetService("UserInputService")
function dragify(Frame)
    local dragToggle, dragStart, startPos, dragInput
    
    local function updateInput(input)
        local delta = input.Position - dragStart
        local newPosition = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        game:GetService("TweenService"):Create(Frame, TweenInfo.new(0.25), {Position = newPosition}):Play()
    end
    
    Frame.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and UIS:GetFocusedTextBox() == nil then
            dragToggle = true
            dragStart = input.Position
            startPos = Frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragToggle = false
                end
            end)
        end
    end)
    
    Frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragToggle then
            updateInput(input)
        end
    end)
end