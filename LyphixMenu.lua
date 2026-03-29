repeat wait() until game:IsLoaded()

    
local players = game:GetService("Players")
local version = require(game:GetService("ReplicatedStorage").Code.assets.gameVersion)

if version.default ~= "3.13.4" then
    local plr = players.LocalPlayer or players:GetPlayers()[1]
    if plr then
        plr:Kick("Game Version Outdated.\nPlease report this to the MoonHub Discord Server. ")
    end
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

-- Costum UI (Orion-kompatibel) + Skript für queue_on_teleport (nach Server-Wechsel erneut ausführen)
local COSTUM_UI_URL = "https://raw.githubusercontent.com/StarterException/Costum1/refs/heads/main/RobloxClientUI.lua"
local LYPHIX_MENU_SCRIPT_URL = "https://raw.githubusercontent.com/StarterException/Costum1/refs/heads/main/LyphixMenu.lua"
-- Wenn readfile verfügbar: zuerst diese lokale Datei nutzen (immer aktuell, kein veraltetes GitHub).
local LOCAL_ROBLOX_CLIENT_UI = "RobloxClientUI.lua"

local function loadRobloxClientUI()
	if LOCAL_ROBLOX_CLIENT_UI ~= "" and readfile then
		for _, path in ipairs({
			LOCAL_ROBLOX_CLIENT_UI,
			"Costum/" .. LOCAL_ROBLOX_CLIENT_UI,
			"Costum\\" .. LOCAL_ROBLOX_CLIENT_UI,
			"./" .. LOCAL_ROBLOX_CLIENT_UI,
		}) do
			local ok, src = pcall(readfile, path)
			if ok and type(src) == "string" and #src > 200 then
				return loadstring(src)()
			end
		end
	end
	return loadstring(game:HttpGet(COSTUM_UI_URL))()
end

local function lyphixTeleportAutoExecPayload()
	return string.format("loadstring(game:HttpGet(%q))()", LYPHIX_MENU_SCRIPT_URL)
end

-- Server-Hop-Sammelpunkt (Fahrzeug) — auch außerhalb des Menü-Blocks für performServerHop
local SERVER_HOP_SAFE_POSITION = Vector3.new(-1292.9005126953125, -423.63556671142578, 3685.330810546875)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Sofortiges Setzen des Fahrzeugs (kein Tween) — z. B. Server-Hop bei Police in der Nähe
local function lyphixSnapVehicleToPosition(targetPos)
	local plr = Players.LocalPlayer
	if not plr then
		return
	end
	local character = plr.Character or plr.CharacterAdded:Wait()
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local vehiclesFolder = workspace:FindFirstChild("Vehicles")
	local vehicle = vehiclesFolder and vehiclesFolder:FindFirstChild(plr.Name)
	if not vehicle or not humanoid then
		return
	end
	local driveSeat = vehicle:FindFirstChild("DriveSeat", true) or vehicle:FindFirstChildWhichIsA("VehicleSeat", true)
	if not driveSeat then
		return
	end
	vehicle.PrimaryPart = driveSeat
	if humanoid.SeatPart ~= driveSeat then
		local hrp = character:FindFirstChild("HumanoidRootPart")
		if hrp then
			hrp.CFrame = driveSeat.CFrame
		end
		task.wait(0.08)
		driveSeat:Sit(humanoid)
		local t = 0
		while humanoid.SeatPart ~= driveSeat and t < 24 do
			task.wait(0.05)
			t = t + 1
		end
	end
	driveSeat.AssemblyLinearVelocity = Vector3.zero
	driveSeat.AssemblyAngularVelocity = Vector3.zero
	local targetCF = typeof(targetPos) == "CFrame" and targetPos or CFrame.new(targetPos)
	vehicle:PivotTo(targetCF)
	if character:FindFirstChildOfClass("Humanoid") and humanoid.SeatPart == nil then
		driveSeat:Sit(humanoid)
	end
	vehicle:SetAttribute("ParkingBrake", true)
	vehicle:SetAttribute("Locked", true)
end

local webhookStats = {
	bombsPurchased = 0,
	safesRobbed = 0,
	alreadyRobbedIgnored = 0,
	currentBalance = "0",
	currentGold = "—",
}

-- Kumulierte Stats + Hop-Zähler über Teleports (Executor-workspace JSON)
local sessionMeta = {
	hopIndex = 0,
}

local StarterGui = game:GetService("StarterGui")
local PlaceId = game.PlaceId

local request = syn and syn.request or http and http.request or http_request or fluxus and fluxus.request or request
local queue_on_teleport = syn and syn.queue_on_teleport or queue_on_teleport or fluxus and fluxus.queue_on_teleport

local TeleportService = game:GetService("TeleportService")

local SERVER_HISTORY_FILE = "ServerHistory.json"
local MAX_HISTORY_SIZE = 20

-- Dieselben Dateien wie im Menü-Block; Webhook muss von hier aus geladen werden (Server-Hop vor UI).
local CONFIG_AUTOROB = "LyphixEmergencyHamburg_autorob.json"
local CONFIG_AUTOROB_LEGACY = "MoonHubAutoRob-premium_config5.json"
local CONFIG_WEBHOOK_FALLBACK = "premium_config.json"

local function trimStr(s)
	if s == nil then
		return ""
	end
	return (tostring(s):gsub("^%s+", ""):gsub("%s+$", ""))
end

local webhookUrl = ""

local function loadWebhookFromFiles()
	if not (isfile and readfile) then
		return
	end
	for _, path in ipairs({
		CONFIG_AUTOROB,
		CONFIG_AUTOROB_LEGACY,
		CONFIG_WEBHOOK_FALLBACK,
	}) do
		if isfile(path) then
			local ok, data = pcall(function()
				return HttpService:JSONDecode(readfile(path))
			end)
			if ok and type(data) == "table" and data.webhookUrl ~= nil then
				local w = trimStr(data.webhookUrl)
				if w ~= "" then
					webhookUrl = w
					return
				end
			end
		end
	end
end

loadWebhookFromFiles()

local function loadSessionStatsFromDisk()
	if not (isfile and readfile) then
		return
	end
	for _, path in ipairs({
		CONFIG_AUTOROB,
		CONFIG_AUTOROB_LEGACY,
	}) do
		if isfile(path) then
			local ok, data = pcall(function()
				return HttpService:JSONDecode(readfile(path))
			end)
			if ok and type(data) == "table" and data.sessionStats then
				local s = data.sessionStats
				webhookStats.bombsPurchased = tonumber(s.bombsPurchased) or webhookStats.bombsPurchased
				webhookStats.safesRobbed = tonumber(s.safesRobbed) or webhookStats.safesRobbed
				webhookStats.alreadyRobbedIgnored = tonumber(s.alreadyRobbedIgnored) or webhookStats.alreadyRobbedIgnored
				sessionMeta.hopIndex = tonumber(s.hopIndex) or sessionMeta.hopIndex
				break
			end
		end
	end
end

loadSessionStatsFromDisk()

local function persistSessionStats()
	if not (writefile and readfile and isfile) then
		return
	end
	local path = CONFIG_AUTOROB
	local data = {}
	if isfile(path) then
		local ok, d = pcall(function()
			return HttpService:JSONDecode(readfile(path))
		end)
		if ok and type(d) == "table" then
			data = d
		end
	elseif isfile(CONFIG_AUTOROB_LEGACY) then
		local ok, d = pcall(function()
			return HttpService:JSONDecode(readfile(CONFIG_AUTOROB_LEGACY))
		end)
		if ok and type(d) == "table" then
			data = d
		end
	end
	data.sessionStats = {
		bombsPurchased = webhookStats.bombsPurchased,
		safesRobbed = webhookStats.safesRobbed,
		alreadyRobbedIgnored = webhookStats.alreadyRobbedIgnored,
		hopIndex = sessionMeta.hopIndex,
	}
	pcall(function()
		writefile(path, HttpService:JSONEncode(data))
	end)
end

-- Kein writefile pro Loot — zusammengefasst (sonst Spam + Lag)
local persistSessionStatsScheduleSeq = 0
local PERSIST_SESSION_DEBOUNCE_SEC = 4

local function schedulePersistSessionStats()
	persistSessionStatsScheduleSeq = persistSessionStatsScheduleSeq + 1
	local seq = persistSessionStatsScheduleSeq
	task.delay(PERSIST_SESSION_DEBOUNCE_SEC, function()
		if seq == persistSessionStatsScheduleSeq then
			persistSessionStats()
		end
	end)
end

local function recordLootStat(isMoneyLoot)
	if isMoneyLoot then
		webhookStats.safesRobbed = webhookStats.safesRobbed + 1
	else
		webhookStats.alreadyRobbedIgnored = webhookStats.alreadyRobbedIgnored + 1
	end
	schedulePersistSessionStats()
end

local function recordBombPurchase()
	webhookStats.bombsPurchased = webhookStats.bombsPurchased + 1
	schedulePersistSessionStats()
end

-- Server-Hop Webhook: nicht bei jedem Hop (Discord / Rate)
local lastServerHopWebhookTime = 0
local SERVER_HOP_WEBHOOK_COOLDOWN_SEC = 90

local function loadServerHistory()
    if isfile and isfile(SERVER_HISTORY_FILE) then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(SERVER_HISTORY_FILE))
        end)
        if success and type(data) == "table" then
            return data
        end
    end
    return {}
end

local function saveServerHistory(history)
    if writefile then
        pcall(function()
            writefile(SERVER_HISTORY_FILE, HttpService:JSONEncode(history))
        end)
    end
end

local function addCurrentServerToHistory()
    local currentJobId = game.JobId
    if not currentJobId then return end
    
    local history = loadServerHistory()
    
    for _, serverId in ipairs(history) do
        if serverId == currentJobId then
            return
        end
    end
    
    table.insert(history, 1, currentJobId)
    
    if #history > MAX_HISTORY_SIZE then
        table.remove(history)
    end
    
    saveServerHistory(history)
end

local function findNewServer()
    local currentJobId = game.JobId
    local history = loadServerHistory()
    
    local url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Desc&limit=100", game.PlaceId)
    
    local success, result = pcall(function()
        local response = game:HttpGet(url)
        return HttpService:JSONDecode(response)
    end)
    
    if not success or not result or not result.data then
        warn("[ServerHop] Error calling ServerList API")
        return nil
    end
    
    local goodServers = {}
    local anyServers = {}    
    
    print(string.format("[ServerHop] Found Servers: %d", #result.data))
    
    for _, server in ipairs(result.data) do
        if server.id and server.playing and server.maxPlayers then
            local serverId = tostring(server.id)
            
            local inHistory = false
            for _, histId in ipairs(history) do
                if histId == serverId then
                    inHistory = true
                    break
                end
            end
            
            if serverId ~= currentJobId and not inHistory then
                if server.playing < server.maxPlayers and server.playing > 1 then
                    table.insert(anyServers, server)
                    if server.playing >= 15 then
                        table.insert(goodServers, server)
                    end
                end
            end
        end
    end
    
    print(string.format("[ServerHop] Available Servers: %d (Good Servers: %d)", #anyServers, #goodServers))
    
    if #goodServers > 0 then
        local selected = goodServers[math.random(1, #goodServers)]
        print(string.format("[ServerHop] Selected Good Server: %s (%d/%d Players)", selected.id, selected.playing, selected.maxPlayers))
        return selected
    elseif #anyServers > 0 then
        local selected = anyServers[math.random(1, #anyServers)]
        print(string.format("[ServerHop] Selected Server: %s (%d/%d Players)", selected.id, selected.playing, selected.maxPlayers))
        return selected
    end
    
    return nil
end

local function snapshotBalancesFromGui()
	local p = game.Players.LocalPlayer
	if not p then
		return
	end
	local pg = p:FindFirstChild("PlayerGui")
	if not pg then
		return
	end
	local bestCashNum = -1
	local bestCashStr = tostring(webhookStats.currentBalance or "0")
	local bestGoldNum = -1
	local bestGoldStr = webhookStats.currentGold or "—"

	local function scoreToken(s)
		if not s or s == "" then
			return -1
		end
		s = tostring(s)
		local lower = string.lower(s)
		local mult = 1
		if string.find(lower, "k", 1, true) then
			mult = 1000
		end
		if string.find(lower, "m", 1, true) then
			mult = 1000000
		end
		local base = tonumber(string.match(s, "([%d%.]+)"))
		if not base then
			return -1
		end
		return math.floor(base * mult + 0.5)
	end

	for _, e in pairs(pg:GetDescendants()) do
		if (e:IsA("TextLabel") or e:IsA("TextButton") or e:IsA("TextBox")) and e.Text and e.Text ~= "" then
			local t = e.Text
			if string.find(t, "€", 1, true) then
				local amount = string.match(t, "([%d%.]+[kKmM]?)%s*€")
				if amount then
					local sc = scoreToken(amount)
					if sc > bestCashNum then
						bestCashNum = sc
						bestCashStr = amount
					end
				end
			end
			local goldAmt = string.match(t, "([%d%.]+[kKmM]?)%s*[Gg]old")
				or string.match(t, "[Gg]old[%s:%-_]*([%d%.]+[kKmM]?)")
			if goldAmt then
				local sg = scoreToken(goldAmt)
				if sg > bestGoldNum then
					bestGoldNum = sg
					bestGoldStr = goldAmt
				end
			end
		end
	end

	if bestCashNum >= 0 then
		webhookStats.currentBalance = bestCashStr
	end
	if bestGoldNum >= 0 then
		webhookStats.currentGold = bestGoldStr .. " Gold"
	else
		webhookStats.currentGold = "—"
	end
end

local function getPoliceNearbyInfo()
	local pl = player
	local char = pl and pl.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return false, nil
	end
	local nearest = nil
	local nearby = false
	for _, other in ipairs(game:GetService("Players"):GetPlayers()) do
		if other ~= pl and other.Team and other.Team.Name == "Police" then
			local oc = other.Character
			local ohrp = oc and oc:FindFirstChild("HumanoidRootPart")
			if ohrp then
				local d = (ohrp.Position - hrp.Position).Magnitude
				if d <= 150 then
					nearby = true
					if not nearest or d < nearest then
						nearest = d
					end
				end
			end
		end
	end
	return nearby, nearest
end

-- reason: "server_hop" | "manual" | "test" — compact English, no spam (hop cooldown)
local function sendSessionReport(info)
	info = info or {}
	local reason = info.reason or "manual"
	snapshotBalancesFromGui()

	local p = game.Players.LocalPlayer
	local url = trimStr(webhookUrl)
	if url == "" then
		return false
	end

	local playerName = p and p.Name or "Unknown"
	local jobId = tostring(game.JobId or "")
	local placeId = game.PlaceId
	local playing = #game:GetService("Players"):GetPlayers()

	local policeNearby = info.policeNearby
	local policeDist = info.policeDistance
	if policeNearby == nil and reason == "server_hop" then
		policeNearby, policeDist = getPoliceNearbyInfo()
	end
	policeNearby = policeNearby and true or false

	if reason == "server_hop" and not info.forceWebhook then
		local now = os.time()
		if now - lastServerHopWebhookTime < SERVER_HOP_WEBHOOK_COOLDOWN_SEC then
			return true
		end
		lastServerHopWebhookTime = now
	end

	local hopNo = tonumber(sessionMeta.hopIndex) or 0
	local leaveCash = tostring(webhookStats.currentBalance or "?")
	local leaveGold = tostring(webhookStats.currentGold or "?")

	local policeTag = policeNearby and "POLICE" or "clear"
	local embedColor
	local title
	if policeNearby then
		embedColor = 16711680
		title = "Lyphix · " .. policeTag .. " · hop #" .. tostring(hopNo)
	elseif reason == "server_hop" then
		embedColor = 15158332
		title = "Lyphix · hop #" .. tostring(hopNo)
	elseif reason == "test" then
		embedColor = 3447003
		title = "Lyphix · webhook test"
	else
		embedColor = 5793266
		title = "Lyphix snap"
	end

	local jobShort = #jobId > 10 and (string.sub(jobId, 1, 10) .. "…") or jobId
	local policeExtra = ""
	if policeNearby and policeDist then
		policeExtra = string.format(" · nearest ~%.0f", policeDist)
	end

	local desc = string.format(
		"**%s** · cash **%s €** · gold **%s**\nPolice **%s**%s · bombs **%d** · safes **%d** · skip **%d**\nPlace **%d** · job `%s` · online **%d**",
		playerName,
		leaveCash,
		leaveGold,
		policeTag,
		policeExtra,
		webhookStats.bombsPurchased,
		webhookStats.safesRobbed,
		webhookStats.alreadyRobbedIgnored,
		placeId,
		jobShort,
		playing
	)

	local payload = {
		username = "Lyphix",
		embeds = {
			{
				title = title,
				description = desc,
				color = embedColor,
				footer = { text = "Emergency Hamburg" },
				timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
			},
		},
	}

	local encoded = HttpService:JSONEncode(payload)
	local requestFunc = request or http_request or (syn and syn.request) or (fluxus and fluxus.request)

	if not requestFunc then
		warn("ERROR: No HTTP request function available for webhooks.")
		return false
	end

	local lastErr
	for attempt = 1, 3 do
		local ok, response = pcall(function()
			return requestFunc({
				Url = url,
				Method = "POST",
				Headers = { ["Content-Type"] = "application/json" },
				Body = encoded,
			})
		end)
		if not ok then
			lastErr = tostring(response)
		else
			local status = tonumber(response and (response.StatusCode or response.statusCode or response.Status))
			if not status or (status >= 200 and status < 300) then
				return true
			end
			if status == 429 then
				lastErr = "HTTP 429 Rate limit"
				task.wait(1.4 * attempt)
			else
				lastErr = tostring(status) .. (response and response.Body and (": " .. tostring(response.Body):sub(1, 180)) or "")
				break
			end
		end
		task.wait(0.65 * attempt)
	end

	warn("[Webhook] Failed after retries: " .. tostring(lastErr))
	return false
end

local isServerHopping = false

local function performServerHop()
	if isServerHopping then
		return
	end
	isServerHopping = true

	pcall(function()
		if LyphixCancelVehicleTween then
			LyphixCancelVehicleTween()
		end
	end)

	print("[ServerHop] Starting server hop...")

	local policeNearby, policeDist = getPoliceNearbyInfo()
	snapshotBalancesFromGui()
	sessionMeta.hopIndex = (tonumber(sessionMeta.hopIndex) or 0) + 1
	persistSessionStatsScheduleSeq = persistSessionStatsScheduleSeq + 1
	persistSessionStats()

	sendSessionReport({
		reason = "server_hop",
		policeNearby = policeNearby,
		policeDistance = policeDist,
	})

	addCurrentServerToHistory()

    local payload = lyphixTeleportAutoExecPayload()

    local q = queue_on_teleport or (syn and syn.queue_on_teleport)
    if q then
        q(payload)
        print("[ServerHop] Auto-execution for next server set up.")
    end

    if policeNearby then
        StarterGui:SetCore("SendNotification", {
            Title = "Police Nearby",
            Text = "Holding server hop position (no tween)...",
            Duration = 2
        })

        pcall(function()
            if LyphixCancelVehicleTween then
                LyphixCancelVehicleTween()
            end
        end)
        pcall(function()
            lyphixSnapVehicleToPosition(SERVER_HOP_SAFE_POSITION)
        end)

        isServerHopping = true
        player:Kick("Searching for new server. Server hop happens automatically...")
        task.wait(1.5)

        local newServer = findNewServer()
        if newServer then
            pcall(function()
                TeleportService:TeleportToPlaceInstance(game.PlaceId, newServer.id, player)
            end)
        else
            pcall(function()
                TeleportService:Teleport(game.PlaceId, player)
            end)
        end
    else
        isServerHopping = true
        player:Kick("Searching for new server. Server hop happens automatically...")
        task.wait(1.5)

        local newServer = findNewServer()
        if newServer then
            print(string.format("[ServerHop] Attempting to teleport to server %s", newServer.id))
            local success, err = pcall(function()
                TeleportService:TeleportToPlaceInstance(game.PlaceId, newServer.id, player)
            end)
            if not success then
                warn("[ServerHop] Direct teleport encountered an error: " .. err)
                task.wait(2)
                pcall(function()
                    TeleportService:Teleport(game.PlaceId, player)
                end)
            end
        else
            print("[ServerHop] No server found → Normal teleport")
            task.wait(1)
            pcall(function()
                TeleportService:Teleport(game.PlaceId, player)
            end)
        end
    end
    
    task.spawn(function()
        task.wait(5)
        isServerHopping = false
    end)
end

local function notify(title, text)
    StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = 2 
    })
end

local gameId = game.PlaceId
local autoRejoin = false

player.AncestryChanged:Connect(function(_, parent)
    if autoRejoin and not isServerHopping and parent == nil then
        local payload = lyphixTeleportAutoExecPayload()

        local q = queue_on_teleport or (syn and syn.queue_on_teleport)
        if q then
            q(payload)
            print("[ServerHop] Auto-execution for next server set up.")
        end

        task.wait(1)
        game:GetService("TeleportService"):Teleport(gameId)
    end
end)

pcall(function()
    game:GetService("CoreGui").RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
        if autoRejoin and not isServerHopping and child.Name == "ErrorPrompt" then
            task.wait(1)
            game:GetService("TeleportService"):Teleport(gameId)
        end
    end)
end)

local PrisonMessageSent = false
local prisonCheckStarted = false

task.spawn(function()
    while true do
        task.wait(0.5)  
        
        local team = player.Team
        if team then
            if team.Name == "Prisoner" then
                if PrisonMessageSent == false then
                    notify("MoonHub AutoRob", "You are in prison - Waiting for release.")
                    PrisonMessageSent = true
                    prisonCheckStarted = false
                end
                warn("[Prison Check] Team: Prisoner")
            elseif team.Name == "Citizen" then
                if not prisonCheckStarted then
                    PrisonMessageSent = false
                    prisonCheckStarted = true
                    
                    notify("MoonHub AutoRob", "Starting AutoRob...")  
                    if game.PlaceId == 7711635737 then
                        task.wait(0.5)

                        local OrionLib
                        local success, err = pcall(function()
                            OrionLib = loadRobloxClientUI()
                        end)
                        
                        if not success or not OrionLib then
                            warn("[ERROR] Failed to load Orion Library: " .. tostring(err))
                            prisonCheckStarted = false
                            return
                        end

                        -- Costum/RobloxClientUI: Fenster-Config wie OrionLib:MakeWindow erwartet (Lucide-Keys oder rbxassetid)
                        local Win = OrionLib:MakeWindow({
                            Name = "Lyphix · Emergency Hamburg",
                            IntroEnabled = false,
                            ShowIcon = true,
                            Icon = "layout-dashboard",
                            BrandName = "Lyphix",
                            BrandTag = "Emergency Hamburg",
                            SaveConfig = false,
                            HidePremium = true,
                            PremiumKeyUI = false,
                        })

                        local InfosTab = Win:MakeTab({
                            Name = "Infos",
                            Icon = "info",
                            PremiumOnly = false,
                        })

                        local AutoRobTab = Win:MakeTab({
                            Name = "AutoRob",
                            Icon = "package",
                            PremiumOnly = false,
                        })

                        local WebhookTab = Win:MakeTab({
                            Name = "Webhook",
                            Icon = "send",
                            PremiumOnly = false,
                        })

                        local Section1 = AutoRobTab:AddSection({ Name = "AutoRob" })
                        local Section = InfosTab:AddSection({ Name = 'General' })

                        AutoRobTab:AddParagraph("Important", 'Please read "Infos" before starting AutoRob!')
                        InfosTab:AddButton({
                            Name = "Join Discord",
                            Callback = function()
                                local success = pcall(function()
                                    if request then
                                        request({
                                            Url = "http://127.0.0.1:6463/rpc?v=1",
                                            Method = "POST",
                                            Headers = {
                                                ["Content-Type"] = "application/json",
                                                ["Origin"] = "https://discord.com"
                                            },
                                            Body = game:GetService("HttpService"):JSONEncode({
                                                cmd = "INVITE_BROWSER",
                                                args = { code = "moon-hub" },
                                                nonce = tostring(math.random(1, 1000000))
                                            })
                                        })
                                    end
                                end)
                                
                                if not success then
                                    setclipboard("https://discord.gg/moon-hub")
                                    game:GetService("StarterGui"):SetCore("SendNotification", {
                                        Title = "Discord Invite";
                                        Text = "Link copied. Please paste it in your browser.";
                                        Duration = 5;
                                    })
                                end
                            end
                        })
                        InfosTab:AddParagraph("Premium AutoRob", "You are currently using the Premium AutoRob from MoonHub.")

                        InfosTab:AddSection({ Name = "Others" })
                        InfosTab:AddParagraph("Other Issues", "If you have any other issues, please open a ticket in our\nDiscord Server")

                        local configFileName = CONFIG_AUTOROB
                        local configFileNameLegacy = CONFIG_AUTOROB_LEGACY

                        local autorobBankClubToggle = false
                        local autorobContainersToggle = false
                        local autoSellToggle = false
                        local tweenSpeed = 175  
                        local AutoTeleportEnabled = true
                        local vehicleSpeedDivider = tweenSpeed
                        local abortHealth = 45
                        local plrTweenSpeed = 50
                        local policeAbort = 25
                        local bombDetectionEnabled = true
                        local PlayerTeleportEnabled = false
                        local invisibleEnabled = false


                        local robMode = "Rob Club & Bank"

                        local EMOTE_ID        = "94292601332790"
                        local STOP_ON_MOVE    = false
                        local ALLOW_INVISIBLE = true
                        local FADE_IN         = 0.1
                        local FADE_OUT        = 0.1
                        local WEIGHT          = 1
                        local SPEED           = 1
                        local TIME_POSITION   = 0

                        cloneref = (type(cloneref) == "function") and cloneref or function(...) return ... end
                        local InvServices = setmetatable({}, { __index = function(_, n) return cloneref(game:GetService(n)) end })
                        local RunService = InvServices.RunService

                        local invCharacter = player.Character or player.CharacterAdded:Wait()
                        local invHumanoid  = invCharacter:WaitForChild("Humanoid")
                        player.CharacterAdded:Connect(function(c)
                            invCharacter = c
                            invHumanoid  = c:WaitForChild("Humanoid")
                        end)

                        local CurrentTrack
                        local lastPosition = invCharacter.PrimaryPart and invCharacter.PrimaryPart.Position or Vector3.new()
                        local originalCollisions = {}

                        local function saveCollisions()
                            for _, p in ipairs(invCharacter:GetDescendants()) do
                                if p:IsA("BasePart") then originalCollisions[p] = p.CanCollide end
                            end
                        end

                        local function disableCollisions()
                            for _, p in ipairs(invCharacter:GetDescendants()) do
                                if p:IsA("BasePart") then p.CanCollide = false end
                            end
                        end

                        local function restoreCollisions()
                            for p, state in pairs(originalCollisions) do
                                if p and p.Parent then p.CanCollide = state end
                            end
                            originalCollisions = {}
                        end

                        local function startEmote()
                            if CurrentTrack then CurrentTrack:Stop(0) end
                            local id = tonumber(EMOTE_ID) or tonumber(string.match(EMOTE_ID, "%d+"))
                            if not id then return end
                            local animId = "rbxassetid://" .. id
                            pcall(function()
                                local objs = game:GetObjects(animId)
                                if objs and #objs > 0 and objs[1]:IsA("Animation") then
                                    animId = objs[1].AnimationId
                                end
                            end)
                            local anim = Instance.new("Animation")
                            anim.AnimationId = animId
                            local track = invHumanoid:LoadAnimation(anim)
                            track.Priority = Enum.AnimationPriority.Action4
                            track:Play(FADE_IN, WEIGHT == 0 and 0.001 or WEIGHT, SPEED)
                            CurrentTrack = track
                            CurrentTrack.TimePosition = math.clamp(TIME_POSITION, 0, 1) * CurrentTrack.Length
                            if ALLOW_INVISIBLE then saveCollisions() disableCollisions() end
                        end

                        local function stopEmote()
                            if CurrentTrack then CurrentTrack:Stop(FADE_OUT) CurrentTrack = nil end
                            restoreCollisions()
                        end

                        local function setLocalInvisibility()
                            if not invisibleEnabled then
                                for _, part in ipairs(invCharacter:GetDescendants()) do
                                    if part:IsA("BasePart") or part:IsA("Decal") then
                                        part.Transparency = 0
                                    end
                                end
                                return
                            end
                            
                            for _, part in ipairs(invCharacter:GetDescendants()) do
                                if part:IsA("BasePart") or part:IsA("Decal") then
                                    part.Transparency = 1
                                end
                            end
                        end

                        invCharacter.DescendantAdded:Connect(function(descendant)
                            if invisibleEnabled and (descendant:IsA("BasePart") or descendant:IsA("Decal")) then
                                descendant.Transparency = 1
                            end
                        end)

                        RunService.RenderStepped:Connect(function()
                            if not invisibleEnabled then return end
                            if STOP_ON_MOVE and CurrentTrack and CurrentTrack.IsPlaying and invCharacter.PrimaryPart then
                                if (invCharacter.PrimaryPart.Position - lastPosition).Magnitude > 0.1 then
                                    stopEmote()
                                    invisibleEnabled = false
                                    setLocalInvisibility()
                                end
                                lastPosition = invCharacter.PrimaryPart.Position
                            end
                        end)

                        RunService.Stepped:Connect(function()
                            if invisibleEnabled and ALLOW_INVISIBLE and invCharacter and invCharacter.Parent then
                                disableCollisions()
                            end
                        end)

                        local function loadConfig()
                            local path = (isfile(configFileName) and configFileName)
                                or (isfile(configFileNameLegacy) and configFileNameLegacy)
                                or nil
                            if path then
                                local data = readfile(path)
                                local success, config = pcall(function() return game:GetService("HttpService"):JSONDecode(data) end)
                                if success and config then
                                    autorobBankClubToggle = config.autorobBankClubToggle or false
                                    autorobContainersToggle = config.autorobContainersToggle or false
                                    autoSellToggle = config.autoSellToggle or false
                                    tweenSpeed = tonumber(config.tweenSpeed) or tweenSpeed
                                    plrTweenSpeed = tonumber(config.plrTweenSpeed) or plrTweenSpeed
                                    abortHealth = tonumber(config.abortHealth) or abortHealth
                                    policeAbort = tonumber(config.policeAbort) or policeAbort
                                    if config.bombDetectionEnabled ~= nil then
                                        bombDetectionEnabled = config.bombDetectionEnabled
                                    end
                                    if config.invisibleEnabled ~= nil then
                                        invisibleEnabled = config.invisibleEnabled
                                    end
                                    if config.autoRejoin ~= nil then
                                        autoRejoin = config.autoRejoin
                                    end
                                    if config.robMode ~= nil then
                                        robMode = config.robMode
                                    end
                                    if config.webhookUrl ~= nil then
                                        webhookUrl = trimStr(config.webhookUrl)
                                    end
                                    if config.sessionStats then
                                        local s = config.sessionStats
                                        webhookStats.bombsPurchased = tonumber(s.bombsPurchased) or webhookStats.bombsPurchased
                                        webhookStats.safesRobbed = tonumber(s.safesRobbed) or webhookStats.safesRobbed
                                        webhookStats.alreadyRobbedIgnored = tonumber(s.alreadyRobbedIgnored) or webhookStats.alreadyRobbedIgnored
                                        sessionMeta.hopIndex = tonumber(s.hopIndex) or sessionMeta.hopIndex
                                    end
                                end
                            end
                        end

                        local function saveConfig()
                            local config = {
                                autorobBankClubToggle = autorobBankClubToggle,
                                autorobContainersToggle = autorobContainersToggle,
                                autoSellToggle = autoSellToggle,
                                plrTweenSpeed = plrTweenSpeed,
                                tweenSpeed = tweenSpeed,
                                abortHealth = abortHealth,
                                policeAbort = policeAbort,
                                bombDetectionEnabled = bombDetectionEnabled,
                                invisibleEnabled = invisibleEnabled,
                                autoRejoin = autoRejoin,
                                webhookUrl = trimStr(webhookUrl),
                                robMode = robMode,
                                sessionStats = {
                                    bombsPurchased = webhookStats.bombsPurchased,
                                    safesRobbed = webhookStats.safesRobbed,
                                    alreadyRobbedIgnored = webhookStats.alreadyRobbedIgnored,
                                    hopIndex = sessionMeta.hopIndex,
                                },
                            }
                            local json = game:GetService("HttpService"):JSONEncode(config)
                            if writefile then
                                pcall(function()
                                    writefile(configFileName, json)
                                end)
                            end
                        end

                        loadConfig()

                        if invisibleEnabled then
                            startEmote()
                            setLocalInvisibility()
                        end

                        local WebhookSection = WebhookTab:AddSection({ Name = "Discord Webhook Settings" })

                        WebhookTab:AddTextbox({
                            Name = "Webhook URL",
                            Default = webhookUrl,
                            TextDisappear = true,
                            Callback = function(Value)
                                webhookUrl = trimStr(Value)
                                saveConfig()
                            end
                        })

                        WebhookTab:AddButton({
                            Name = "Sessionbericht senden",
                            Callback = function()
                                snapshotBalancesFromGui()
                                persistSessionStats()
                                local success = sendSessionReport({ reason = "manual" })
                                if success then
                                    OrionLib:MakeNotification({
                                        Name = "Webhook",
                                        Content = "Sessionbericht gesendet.",
                                        Image = "rbxassetid://4483345998",
                                        Time = 3
                                    })
                                else
                                    OrionLib:MakeNotification({
                                        Name = "Fehler",
                                        Content = "Webhook konnte nicht gesendet werden (URL prüfen).",
                                        Image = "rbxassetid://4483345998",
                                        Time = 4
                                    })
                                end
                            end
                        })

                        WebhookTab:AddButton({
                            Name = "Test Webhook",
                            Callback = function()
                                local success = sendSessionReport({ reason = "test" })
                                
                                if success then
                                    OrionLib:MakeNotification({
                                        Name = "Success",
                                        Content = "Webhook sent successfully!",
                                        Image = "rbxassetid://4483345998",
                                        Time = 3
                                    })
                                else
                                    OrionLib:MakeNotification({
                                        Name = "Error",
                                        Content = "Failed to send webhook. Check URL.",
                                        Image = "rbxassetid://4483345998",
                                        Time = 3
                                    })
                                end
                            end
                        })

                        WebhookTab:AddParagraph("Stats", string.format(
                            "Bomben: %d\nSafes: %d\nIgnoriert: %d\nBargeld (UI): %s €\nGold (UI): %s",
                            webhookStats.bombsPurchased,
                            webhookStats.safesRobbed,
                            webhookStats.alreadyRobbedIgnored,
                            tostring(webhookStats.currentBalance),
                            tostring(webhookStats.currentGold)
                        ))

                        WebhookTab:AddParagraph(
                            "Hinweis",
                            "Discord: Hop-Webhooks EN, kompakt, max. ca. alle 90s (weniger Spam). Manuelle/Test-Buttons senden immer. Zähler landen trotzdem in der JSON."
                        )

                        AutoRobTab:AddToggle({
                            Name = "AutoRob",
                            Default = autorobBankClubToggle,
                            Callback = function(Value)
                                autorobBankClubToggle = Value
                                saveConfig()
                            end    
                        })

                        AutoRobTab:AddDropdown({
                            Name = "Rob Mode",
                            Default = robMode,
                            Options = {
                                "Rob Club & Bank",
                                "Rob Club, Jeweler & Bank"
                            },
                            Callback = function(Value)
                                robMode = Value
                                saveConfig()
                                game.StarterGui:SetCore("SendNotification", {
                                    Title = "Mode Changed",
                                    Text = "Current Mode: " .. Value,
                                    Duration = 3
                                })
                            end
                        })

                        AutoRobTab:AddSection({ Name = 'Options' })

                        AutoRobTab:AddToggle({
                            Name = "Auto Sell Stolen Items",
                            Default = autoSellToggle,
                            Callback = function(Value)
                                autoSellToggle = Value
                                saveConfig()
                            end    
                        })

                        AutoRobTab:AddToggle({
                            Name = "Bomb Nearby Detection",
                            Default = bombDetectionEnabled,
                            Callback = function(Value)
                                bombDetectionEnabled = Value
                                saveConfig()
                            end
                        })

                        AutoRobTab:AddToggle({
                            Name = "Fast Player Teleports",
                            Default = true,
                            Callback = function(Value)
                                PlayerTeleportEnabled = Value
                            end
                        })

                        AutoRobTab:AddToggle({
                            Name = "Invisible",
                            Default = invisibleEnabled,
                            Callback = function(value)
                                invisibleEnabled = value
                                saveConfig()
                                if value then 
                                    startEmote()
                                    setLocalInvisibility()
                                else 
                                    stopEmote()
                                    setLocalInvisibility()
                                end
                            end,
                        })

                        AutoRobTab:AddToggle({
                            Name = "Auto Rejoin When Kicked",
                            Default = autoRejoin,
                            Callback = function(value)
                                autoRejoin = value
                                saveConfig()
                            end
                        })

                        AutoRobTab:AddSection({ Name = 'Settings' })

                        AutoRobTab:AddSlider({
                            Name = "Teleport Speed",
                            Min = 50,
                            Max = 350,
                            Default = tweenSpeed,
                            Increment = 5,
                            ValueName = "Speed",
                            Color = Color3.fromRGB(137, 207, 240),
                            Callback = function(Value)
                                tweenSpeed = Value
                                vehicleSpeedDivider = Value
                                saveConfig()
                            end    
                        })

                        AutoRobTab:AddSlider({
                            Name = "Police Abort Distance",
                            Min = 5,
                            Max = 100,
                            Default = policeAbort,
                            Increment = 1,
                            ValueName = "Studs",
                            Color = Color3.fromRGB(137, 207, 240),
                            Callback = function(Value)
                                policeAbort = Value
                                saveConfig()
                            end    
                        })

                        AutoRobTab:AddSlider({
                            Name = "Player Movement Speed",
                            Min = 10,
                            Max = 200,
                            Default = plrTweenSpeed,
                            Increment = 1,
                            ValueName = "Speed",
                            Color = Color3.fromRGB(137, 207, 240),
                            Callback = function(Value)
                                plrTweenSpeed = Value
                                saveConfig()
                            end    
                        })

                        AutoRobTab:AddSlider({
                            Name = "Abort at Health",
                            Min = 25,
                            Max = 80,
                            Default = abortHealth,
                            Increment = 1,
                            ValueName = "HP",
                            Color = Color3.fromRGB(137, 207, 240),
                            Callback = function(Value)
                                abortHealth = Value
                                saveConfig()
                            end    
                        })

                        local plr = game:GetService("Players").LocalPlayer
                        local buyRemoteEvent = game:GetService("ReplicatedStorage"):WaitForChild("EJw"):WaitForChild("29c2c390-e58d-4512-9180-2da58f0d98d8")
                        local EquipRemoteEvent = game:GetService("ReplicatedStorage"):WaitForChild("EJw"):WaitForChild("b16cb2a5-7735-4e84-a72b-22718da109fc")
                        local fireBombRemoteEvent = game:GetService("ReplicatedStorage"):WaitForChild("EJw"):WaitForChild("66291b15-ebda-4dbd-964e-cc89f86d2c82")
                        local robRemoteEvent = game:GetService("ReplicatedStorage"):WaitForChild("EJw"):WaitForChild("a3126821-130a-4135-80e1-1d28cece4007")
                        local sellRemoteEvent = game:GetService("ReplicatedStorage"):WaitForChild("EJw"):WaitForChild("eb233e6a-acb9-4169-acb9-129fe8cb06bb")
                        local ProximityPromptTimeBet = 2.5
                        local VirtualInputManager = game:GetService("VirtualInputManager")
                        local key = Enum.KeyCode.E
                        local TweenService = game:GetService("TweenService")
                        local RunService = game:GetService("RunService")

                        -- Easing für Tween (Dauer kommt weiterhin aus Slider: Distanz / Speed)
                        local function lyphixEaseInOutCubic(t)
                            t = math.clamp(t, 0, 1)
                            if t < 0.5 then
                                return 4 * t * t * t
                            end
                            return 1 - ((-2 * t + 2) ^ 3) / 2
                        end

                        local function lyphixSmoothstep(t)
                            t = math.clamp(t, 0, 1)
                            return t * t * (3 - 2 * t)
                        end

                        local function clickAtCoordinates(scaleX, scaleY, duration)
                            local camera = game.Workspace.CurrentCamera
                            local screenWidth = camera.ViewportSize.X
                            local screenHeight = camera.ViewportSize.Y
                            local absoluteX = screenWidth * scaleX
                            local absoluteY = screenHeight * scaleY
                            VirtualInputManager:SendMouseButtonEvent(absoluteX, absoluteY, 0, true, game, 0)
                            if duration and duration > 0 then
                                task.wait(duration)
                            end
                            VirtualInputManager:SendMouseButtonEvent(absoluteX, absoluteY, 0, false, game, 0)
                        end

                        local teleportActive   = false
                        local currentTween     = nil
                        local currentTweenConn = nil

                        local function stopCurrentTween()
                            if currentTween then
                                currentTween:Cancel()
                                currentTween = nil
                            end
                            if currentTweenConn then
                                currentTweenConn:Disconnect()
                                currentTweenConn = nil
                            end
                            teleportActive = false
                        end

                        LyphixCancelVehicleTween = stopCurrentTween

                        local isAborting = false
                        local policeCheckActive = false
                        local policeCheckConnection = nil

                        local function checkForBomb()
                            if not bombDetectionEnabled then return false end

                            local player = game.Players.LocalPlayer
                            if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
                                return false
                            end

                            local playerPos = player.Character.HumanoidRootPart.Position

                            local foldersToCheck = {
                                workspace.Objects and workspace.Objects.Throwables and workspace.Objects.Throwables:FindFirstChild("Bomb"),
                                workspace.Objects and workspace.Objects.Throwables and workspace.Objects.Throwables:FindFirstChild("Grenade")
                            }

                            for _, folder in ipairs(foldersToCheck) do
                                if folder then
                                    for _, bombModel in ipairs(folder:GetChildren()) do
                                        local shouldIgnore = false

                                        local mainPart = bombModel:FindFirstChild("Main")
                                        if mainPart and mainPart:IsA("BasePart") then
                                            local color = mainPart.Color
                                            if math.floor(color.R * 255) == 27 and
                                               math.floor(color.G * 255) == 42 and
                                               math.floor(color.B * 255) == 53 then
                                                shouldIgnore = true
                                            end
                                        end

                                        if not shouldIgnore then
                                            local bombPart = bombModel:FindFirstChild("Handle") or
                                                bombModel:FindFirstChild("MainPart") or
                                                bombModel:FindFirstChildWhichIsA("BasePart")

                                            if bombPart then
                                                if (bombPart.Position - playerPos).Magnitude <= 5 then
                                                    return true
                                                end
                                            else
                                                for _, part in ipairs(bombModel:GetDescendants()) do
                                                    if part:IsA("BasePart") then
                                                        if (part.Position - playerPos).Magnitude <= 5 then
                                                            return true
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                            return false
                        end

                        local function SpawnBomb()
                            if invisibleEnabled then
                                stopEmote()
                            end
                            
                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
                            task.wait(0.1)
                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
                            task.wait(0.1)
                            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                            task.wait(0.1)
                            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                            
                            if invisibleEnabled then
                                startEmote()
                                setLocalInvisibility()
                            end
                        end

                        -- Bombe im Inventar (Backpack/Charakter, auch verschachtelt)
                        local function playerHasBombInInventory(who)
                            who = who or plr
                            if not who then
                                return false
                            end
                            local function containerHasBomb(container)
                                if not container then
                                    return false
                                end
                                for _, d in ipairs(container:GetDescendants()) do
                                    if d:IsA("Tool") and d.Name == "Bomb" then
                                        return true
                                    end
                                end
                                return false
                            end
                            return containerHasBomb(who.Backpack) or containerHasBomb(who.Character)
                        end

                        local function countBombsInInventory(who)
                            who = who or plr
                            if not who then
                                return 0
                            end
                            local function bombCountIn(container)
                                if not container then
                                    return 0
                                end
                                local n = 0
                                for _, d in ipairs(container:GetDescendants()) do
                                    if d:IsA("Tool") and d.Name == "Bomb" then
                                        n = n + 1
                                    end
                                end
                                return n
                            end
                            return bombCountIn(who.Backpack) + bombCountIn(who.Character)
                        end

                        local function equipBombToolFromInventory()
                            local char = plr.Character
                            if not char then
                                return false
                            end
                            local hum = char:FindFirstChildWhichIsA("Humanoid")
                            if not hum then
                                return false
                            end
                            if char:FindFirstChild("Bomb") and char:FindFirstChild("Bomb"):IsA("Tool") then
                                return true
                            end
                            local bombTool = nil
                            for _, d in ipairs(plr.Backpack:GetDescendants()) do
                                if d:IsA("Tool") and d.Name == "Bomb" then
                                    bombTool = d
                                    break
                                end
                            end
                            if not bombTool then
                                return false
                            end
                            if bombTool.Parent ~= plr.Backpack then
                                bombTool.Parent = plr.Backpack
                                task.wait(0.06)
                            end
                            pcall(function()
                                hum:EquipTool(bombTool)
                            end)
                            task.wait(0.12)
                            return char:FindFirstChild("Bomb") ~= nil
                        end

                        local function runBombThrowSequence()
                            EquipRemoteEvent:FireServer("Bomb")
                            task.wait(0.5)
                            if not (plr.Character and plr.Character:FindFirstChild("Bomb")) then
                                equipBombToolFromInventory()
                                task.wait(0.15)
                            end
                            if not (plr.Character and plr.Character:FindFirstChild("Bomb")) then
                                equipBombToolFromInventory()
                                task.wait(0.15)
                            end
                            local tool = plr.Character and plr.Character:FindFirstChild("Bomb")
                            if tool then
                                SpawnBomb()
                            else
                                warn("[Bomb] Tool 'Bomb' not on character after equip — check inventory.")
                            end
                            task.wait(0.5)
                            fireBombRemoteEvent:FireServer()
                        end

                        local function JumpOut()
                            local Players = game:GetService("Players")
                            local LocalPlayer = Players.LocalPlayer    
                            local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                            if character then
                                local humanoid = character:FindFirstChild("Humanoid")
                                if humanoid and humanoid.SeatPart then
                                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                                end
                            end
                        end

                        local function ensurePlayerInVehicle()
                            local player = game:GetService("Players").LocalPlayer
                            local vehicle = workspace:FindFirstChild("Vehicles") and workspace.Vehicles:FindFirstChild(player.Name)
                            local character = player.Character or player.CharacterAdded:Wait()

                            if vehicle and character then
                                local humanoid = character:FindFirstChildWhichIsA("Humanoid")
                                local driveSeat = vehicle:FindFirstChild("DriveSeat", true)
                                    or vehicle:FindFirstChildWhichIsA("VehicleSeat", true)

                                if humanoid and driveSeat and humanoid.SeatPart ~= driveSeat then
                                    driveSeat:Sit(humanoid)
                                end
                            end
                        end

                        local function ensurePlayerInVehicleWithRetries(maxAttempts)
                            maxAttempts = maxAttempts or 22
                            for _ = 1, maxAttempts do
                                ensurePlayerInVehicle()
                                local char = plr.Character
                                local vehicle = workspace.Vehicles and workspace.Vehicles:FindFirstChild(plr.Name)
                                if char and vehicle then
                                    local hum = char:FindFirstChildWhichIsA("Humanoid")
                                    local driveSeat = vehicle:FindFirstChild("DriveSeat", true)
                                        or vehicle:FindFirstChildWhichIsA("VehicleSeat", true)
                                    if hum and driveSeat and hum.SeatPart == driveSeat then
                                        return true
                                    end
                                end
                                task.wait(0.07)
                            end
                            return false
                        end

                        -- Sofort Fahrzeug setzen (kein langes tweenTo) — z. B. Police-Abort: an Server-Hop-Punkt bleiben
                        local function snapVehicleToPosition(targetPos)
                            lyphixSnapVehicleToPosition(targetPos)
                        end

                        local currentPlrTween = nil
                        -- Police-Evakuierung: trotz isAborting Fahrzeug-Tween zur Hop-Position erlauben
                        local policeEvacToHopActive = false
                        local lyphixDealerApproachActive = false

tweenTo = function(destination)
    if isAborting and not policeEvacToHopActive then
        return
    end
    if not policeEvacToHopActive and not lyphixDealerApproachActive then
        clickAtCoordinates(0.45, 0.34)
        clickAtCoordinates(0.5, 0.9)
    end
    if teleportActive then
        stopCurrentTween()
    end
    teleportActive = true

    local character = plr.Character or plr.CharacterAdded:Wait()
    local humanoid  = character:FindFirstChildOfClass("Humanoid")
    local hrp       = character:FindFirstChild("HumanoidRootPart")

    local vehicle = workspace.Vehicles:FindFirstChild(plr.Name)
    if not vehicle then
        teleportActive = false
        OrionLib:MakeNotification({
            Name    = "Error",
            Content = "No vehicle found!",
            Image   = "rbxassetid://79707149144849",
            Duration = 3
        })
        return
    end

    local driveSeat = vehicle:FindFirstChild("DriveSeat", true)
        or vehicle:FindFirstChildWhichIsA("VehicleSeat", true)
    if not driveSeat then
        teleportActive = false
        return
    end
    vehicle.PrimaryPart = driveSeat

    if humanoid and humanoid.SeatPart ~= driveSeat then
        if hrp then hrp.CFrame = driveSeat.CFrame end
        task.wait(0.1)
        driveSeat:Sit(humanoid)
        local t = 0
        while humanoid.SeatPart ~= driveSeat and t < 15 do
            if not teleportActive or (isAborting and not policeEvacToHopActive) then
                teleportActive = false
                return
            end
            task.wait(0.1)
            t = t + 1
        end
    end

    local targetCF  = (typeof(destination) == "CFrame") and destination
                      or CFrame.new(destination)
    local targetPos = targetCF.Position

    local char = plr.Character
    local currentPos = vehicle.PrimaryPart.Position
    local distance = (Vector3.new(currentPos.X, 0, currentPos.Z) - Vector3.new(targetPos.X, 0, targetPos.Z)).Magnitude

    local lowY = -1
    local pivotNow = vehicle:GetPivot()
    vehicle:PivotTo(CFrame.new(Vector3.new(pivotNow.X, lowY, pivotNow.Z)))
    driveSeat.AssemblyLinearVelocity  = Vector3.zero
    driveSeat.AssemblyAngularVelocity = Vector3.zero
    task.wait(0.05)

    if not teleportActive or (isAborting and not policeEvacToHopActive) then
        teleportActive = false
        return
    end

    if distance > 0.5 then
        local startFlat = Vector3.new(pivotNow.X, lowY, pivotNow.Z)
        local endFlat = Vector3.new(targetPos.X, lowY, targetPos.Z)
        local flatDelta = endFlat - startFlat
        local flatDist = flatDelta.Magnitude
        local flatDir = flatDist > 0.05 and flatDelta.Unit or Vector3.new(0, 0, -1)
        local dealerMul = lyphixDealerApproachActive and 2.6 or 1
        local tweenDuration = math.max(flatDist / (vehicleSpeedDivider * dealerMul), lyphixDealerApproachActive and 0.035 or 0.06)
        local t0 = os.clock()

        while true do
            if (isAborting and not policeEvacToHopActive) or not teleportActive then
                teleportActive = false
                currentTween = nil
                if currentTweenConn then
                    currentTweenConn:Disconnect()
                    currentTweenConn = nil
                end
                return
            end
            local u = math.clamp((os.clock() - t0) / tweenDuration, 0, 1)
            local eh = lyphixEaseInOutCubic(u)
            local xzPos = startFlat:Lerp(endFlat, eh)
            local yBlend = lyphixSmoothstep(math.clamp((u - 0.68) / 0.32, 0, 1))
            local y = lowY + (targetPos.Y - lowY) * yBlend
            local pos = Vector3.new(xzPos.X, y, xzPos.Z)
            vehicle:PivotTo(CFrame.lookAt(pos, pos + flatDir))
            driveSeat.AssemblyLinearVelocity = Vector3.zero
            driveSeat.AssemblyAngularVelocity = Vector3.zero
            if u >= 1 then
                break
            end
            RunService.Heartbeat:Wait()
        end
    end

    if (isAborting and not policeEvacToHopActive) or not teleportActive then
        teleportActive = false
        currentTween = nil
        return
    end

    local finalCFrame = CFrame.new(targetPos)
    vehicle:PivotTo(finalCFrame)
    if char and char:FindFirstChild("Humanoid") then
        local humanoid = char.Humanoid
        if humanoid.SeatPart == nil then
            driveSeat:Sit(humanoid)
        end
    end
    vehicle:SetAttribute("ParkingBrake", true)
    vehicle:SetAttribute("Locked", true)

    teleportActive = false
    currentTween = nil
end

                        local function plrTween(destination)
                            if isAborting then
                                return
                            end
                            local plr = game.Players.LocalPlayer
                            local char = plr.Character

                            if not char or not char.PrimaryPart then
                                warn("Character or PrimaryPart not available.")
                                return
                            end

                            local distance = (char.PrimaryPart.Position - destination).Magnitude
                            -- Nur Mini-Sprünge snappen — größere Distanz = echter Tween (wichtig fürs Loot)
                            local instantTpMaxStuds = 14

                            if PlayerTeleportEnabled and distance < instantTpMaxStuds then
                                if currentPlrTween then
                                    pcall(function()
                                        currentPlrTween:Cancel()
                                    end)
                                    currentPlrTween = nil
                                end
                                char:PivotTo(CFrame.new(destination))
                                return
                            end

                            if currentPlrTween then
                                pcall(function()
                                    currentPlrTween:Cancel()
                                end)
                                currentPlrTween = nil
                            end

                            local tweenDuration = math.max(distance / plrTweenSpeed, 0.05)
                            local startCF = char:GetPivot()
                            local flatFrom = Vector3.new(startCF.Position.X, 0, startCF.Position.Z)
                            local flatTo = Vector3.new(destination.X, 0, destination.Z)
                            local walkDir = flatTo - flatFrom
                            local targetCFrame
                            if walkDir.Magnitude > 0.25 then
                                local face = walkDir.Unit
                                targetCFrame = CFrame.lookAt(destination, Vector3.new(destination.X, startCF.Position.Y, destination.Z) + face)
                            else
                                targetCFrame = CFrame.new(destination) * (startCF - startCF.Position)
                            end

                            local TweenInfoToUse = TweenInfo.new(
                                tweenDuration,
                                Enum.EasingStyle.Quint,
                                Enum.EasingDirection.InOut
                            )

                            local TweenValue = Instance.new("CFrameValue")
                            TweenValue.Value = startCF

                            TweenValue.Changed:Connect(function(newCFrame)
                                if isAborting then
                                    return
                                end
                                char:PivotTo(newCFrame)
                            end)

                            local tween = TweenService:Create(TweenValue, TweenInfoToUse, { Value = targetCFrame })

                            currentPlrTween = tween
                            tween:Play()
                            tween.Completed:Wait()
                            currentPlrTween = nil
                            TweenValue:Destroy()
                        end

                        local function checkPoliceNearby()
                            local player = game.Players.LocalPlayer
                            if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then 
                                return false, 999 
                            end
                            
                            local closestDistance = 999
                            local policeFound = false
                            
                            for _, plr in ipairs(game:GetService("Players"):GetPlayers()) do
                                if plr ~= player and plr.Team and plr.Team.Name == "Police" and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                                    local distance = (plr.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                                    if distance < closestDistance then
                                        closestDistance = distance
                                    end
                                    if distance <= policeAbort then
                                        policeFound = true
                                    end
                                end
                            end
                            
                            return policeFound, closestDistance
                        end

                        local function stopPoliceMonitoring()
                            if policeCheckConnection then
                                policeCheckConnection:Disconnect()
                                policeCheckConnection = nil
                            end
                            policeCheckActive = false
                            print("[Police Monitor] Stopped monitoring")
                        end

                        local function startPoliceMonitoring(robberyName)
                            if policeCheckActive then return end
                            policeCheckActive = true
                            isAborting = false
                            
                            print("[Police Monitor] Started monitoring for " .. robberyName)
                            
                            policeCheckConnection = RunService.Heartbeat:Connect(function()
                                if not autorobBankClubToggle and not autorobContainersToggle then
                                    if policeCheckConnection then
                                        policeCheckConnection:Disconnect()
                                        policeCheckConnection = nil
                                    end
                                    policeCheckActive = false
                                    return
                                end
                                
                                if isAborting then return end
                                
                                local policeNearby, distance = checkPoliceNearby()
                                
                                if policeNearby and not isAborting then
                                    isAborting = true
                                    
                                    game.StarterGui:SetCore("SendNotification", {
                                        Title = "Police Nearby",
                                        Text = string.format("Police nearby (%d studs) - Aborting %s robbery!", math.floor(distance), robberyName),
                                        Duration = 5
                                    })
                                    
                                    print(string.format("[Police Monitor] Police detected! Distance: %d studs - Aborting %s", math.floor(distance), robberyName))
                                    
                                    if policeCheckConnection then
                                        policeCheckConnection:Disconnect()
                                        policeCheckConnection = nil
                                    end
                                    policeCheckActive = false

                                    task.spawn(function()
                                        pcall(function()
                                            if LyphixCancelVehicleTween then
                                                LyphixCancelVehicleTween()
                                            end
                                        end)
                                        pcall(function()
                                            if currentPlrTween then
                                                currentPlrTween:Cancel()
                                                currentPlrTween = nil
                                            end
                                        end)
                                        task.wait(0.06)
                                        ensurePlayerInVehicleWithRetries(24)
                                        task.wait(0.08)
                                        policeEvacToHopActive = true
                                        local tweenOk, tweenErr = pcall(function()
                                            tweenTo(SERVER_HOP_SAFE_POSITION)
                                        end)
                                        policeEvacToHopActive = false
                                        if not tweenOk then
                                            warn("[Police Evac] tweenTo failed: " .. tostring(tweenErr))
                                        end
                                        local needsSnap = not tweenOk
                                        if not needsSnap then
                                            local vehiclesFolder = workspace:FindFirstChild("Vehicles")
                                            local v = vehiclesFolder and vehiclesFolder:FindFirstChild(plr.Name)
                                            local seat = v and (v:FindFirstChild("DriveSeat", true) or v:FindFirstChildWhichIsA("VehicleSeat", true))
                                            if seat then
                                                needsSnap = (seat.Position - SERVER_HOP_SAFE_POSITION).Magnitude > 45
                                            else
                                                needsSnap = true
                                            end
                                        end
                                        if needsSnap then
                                            pcall(lyphixSnapVehicleToPosition, SERVER_HOP_SAFE_POSITION)
                                        end
                                        task.wait(0.18)
                                        isAborting = false
                                        if performServerHop then
                                            pcall(performServerHop)
                                        end
                                    end)
                                end
                            end)
                        end

                        -- Unterordner (verschachtelte Parts) + kurze Nachläufe; schmal nur unter diesem folder
                        local LOOT_SWEEP_MAX = 5
                        local LOOT_SWEEP_GAP = 0.1

                        local function isLootableBasePart(ch)
                            return ch:IsA("BasePart") and ch.Transparency < 0.97
                        end

                        local function interactWithVisibleMeshParts(folder)
                            if not folder or isAborting then
                                return
                            end
                            local player = game.Players.LocalPlayer
                            local char = player.Character
                            local hrp = char and char:FindFirstChild("HumanoidRootPart")
                            if not hrp then
                                return
                            end

                            for sweep = 1, LOOT_SWEEP_MAX do
                                if sweep > 1 then
                                    task.wait(LOOT_SWEEP_GAP)
                                end
                                local meshParts = {}
                                for _, ch in ipairs(folder:GetDescendants()) do
                                    if isLootableBasePart(ch) then
                                        table.insert(meshParts, ch)
                                    end
                                end
                                if #meshParts == 0 then
                                    break
                                end
                                table.sort(meshParts, function(a, b)
                                    return (a.Position - hrp.Position).Magnitude < (b.Position - hrp.Position).Magnitude
                                end)

                                for _, meshPart in ipairs(meshParts) do
                                    if isAborting then
                                        return
                                    end
                                    if checkForBomb() then
                                        game.StarterGui:SetCore("SendNotification", {
                                            Title = "Bomb Detection",
                                            Text = "Aborting, detected bomb nearby",
                                            Duration = 3,
                                        })
                                        return
                                    end
                                    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
                                    if hum and hum.Health <= abortHealth then
                                        game.StarterGui:SetCore("SendNotification", {
                                            Title = "Player is hurt",
                                            Text = "Aborting, player is hurt",
                                        })
                                        return
                                    end
                                    if meshPart.Transparency >= 0.97 then
                                        continue
                                    end
                                    if meshPart.Parent and meshPart.Parent.Name == "Money" then
                                        local args = { meshPart, "yQL", true }
                                        robRemoteEvent:FireServer(unpack(args))
                                        task.wait(ProximityPromptTimeBet)
                                        args[3] = false
                                        robRemoteEvent:FireServer(unpack(args))
                                        recordLootStat(true)
                                    else
                                        local args = { meshPart, "Vqe", true }
                                        robRemoteEvent:FireServer(unpack(args))
                                        task.wait(ProximityPromptTimeBet)
                                        args[3] = false
                                        robRemoteEvent:FireServer(unpack(args))
                                        recordLootStat(false)
                                    end
                                end
                            end
                        end

                        local function interactWithVisibleMeshParts2(folder)
                            if not folder or isAborting then
                                return
                            end
                            local player = game.Players.LocalPlayer
                            local char = player.Character
                            local hrp = char and char:FindFirstChild("HumanoidRootPart")
                            if not hrp then
                                return
                            end

                            for sweep = 1, LOOT_SWEEP_MAX do
                                if sweep > 1 then
                                    task.wait(LOOT_SWEEP_GAP)
                                end
                                local meshParts = {}
                                for _, ch in ipairs(folder:GetDescendants()) do
                                    if isLootableBasePart(ch) then
                                        table.insert(meshParts, ch)
                                    end
                                end
                                if #meshParts == 0 then
                                    break
                                end
                                table.sort(meshParts, function(a, b)
                                    return (a.Position - hrp.Position).Magnitude < (b.Position - hrp.Position).Magnitude
                                end)

                                for _, meshPart in ipairs(meshParts) do
                                    if isAborting then
                                        return
                                    end
                                    if checkForBomb() then
                                        game.StarterGui:SetCore("SendNotification", {
                                            Title = "Bomb Detection",
                                            Text = "Aborting, detected bomb nearby",
                                            Duration = 3,
                                        })
                                        return
                                    end
                                    local hum2 = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
                                    if hum2 and hum2.Health <= abortHealth then
                                        game.StarterGui:SetCore("SendNotification", {
                                            Title = "Player is hurt",
                                            Text = "Aborted, player is hurt",
                                        })
                                        return
                                    end
                                    if meshPart.Transparency >= 0.97 then
                                        continue
                                    end
                                    plrTween(meshPart.Position)
                                    if meshPart.Parent and meshPart.Parent.Name == "Money" then
                                        local args3 = { meshPart, "yQL", true }
                                        robRemoteEvent:FireServer(unpack(args3))
                                        task.wait(ProximityPromptTimeBet)
                                        args3[3] = false
                                        robRemoteEvent:FireServer(unpack(args3))
                                        recordLootStat(true)
                                    else
                                        local args4 = { meshPart, "Vqe", true }
                                        robRemoteEvent:FireServer(unpack(args4))
                                        task.wait(ProximityPromptTimeBet)
                                        args4[3] = false
                                        robRemoteEvent:FireServer(unpack(args4))
                                        recordLootStat(false)
                                    end
                                    task.wait(0.085)
                                end
                            end
                        end

                        local function countRemainingLootInFolder(folder)
                            if not folder or isAborting then
                                return 0
                            end
                            local n = 0
                            for _, ch in ipairs(folder:GetDescendants()) do
                                if isLootableBasePart(ch) and ch.Transparency < 0.97 then
                                    n = n + 1
                                end
                            end
                            return n
                        end

                        local function lootSafeUntilClear(itemsFolder, moneyFolder, usePlrTweenPath)
                            local maxRounds = 12
                            for _ = 1, maxRounds do
                                if isAborting then
                                    return
                                end
                                if usePlrTweenPath then
                                    interactWithVisibleMeshParts2(itemsFolder)
                                    interactWithVisibleMeshParts2(moneyFolder)
                                else
                                    interactWithVisibleMeshParts(itemsFolder)
                                    interactWithVisibleMeshParts(moneyFolder)
                                end
                                local left = countRemainingLootInFolder(itemsFolder) + countRemainingLootInFolder(moneyFolder)
                                if left == 0 then
                                    return
                                end
                                task.wait(0.18)
                            end
                        end

                        local function startAutoCollect()
                            local Workspace = game:GetService("Workspace")
                            local Players = game:GetService("Players")

                            local Player = Players.LocalPlayer
                            local Character = Player.Character or Player.CharacterAdded:Wait()
                            local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

                            local Collected = {}
                            local ProximityPromptTimeBet = 2.5
                            local Range = 30
                            local Robberies = {}

                            for _, d in ipairs(Workspace:GetDescendants()) do
                                if d:IsA("Folder") then
                                    local n = d.Name:lower()
                                    if n:find("robbery") or n:find("robberies") then
                                        table.insert(Robberies, d)
                                    end
                                end
                            end

                            Workspace.DescendantAdded:Connect(function(d)
                                if d:IsA("Folder") then
                                    local n = d.Name:lower()
                                    if n:find("robbery") or n:find("robberies") then
                                        table.insert(Robberies, d)
                                    end
                                end
                            end)

                            local function loot(folder)
                                for _, m in ipairs(folder:GetDescendants()) do
                                    if m:IsA("MeshPart") and m.Transparency == 0 then
                                        if HumanoidRootPart and not Collected[m] and (m.Position - HumanoidRootPart.Position).Magnitude <= Range then
                                            Collected[m] = true
                                            task.spawn(function()
                                                local a
                                                if m.Parent and m.Parent.Name == "Money" then
                                                    a = { m, "yQL", true }
                                                else
                                                    a = { m, "Vqe", true }
                                                end
                                                robRemoteEvent:FireServer(unpack(a))
                                                task.wait(ProximityPromptTimeBet)
                                                a[3] = false
                                                robRemoteEvent:FireServer(unpack(a))
                                                local isMoneyLoot = m.Parent and m.Parent.Name == "Money"
                                                recordLootStat(isMoneyLoot)
                                                if m and m.Parent and m.Transparency == 0 then
                                                    Collected[m] = nil
                                                end
                                            end)
                                        end
                                    end
                                end
                            end

                            while autorobBankClubToggle or autorobContainersToggle do
                                for _, r in ipairs(Robberies) do
                                    if r and r.Parent then
                                        loot(r)
                                    end
                                end
                                task.wait(0.5)
                            end
                        end

                        local function MoveToDealer()
                            local player = game:GetService("Players").LocalPlayer
                            local character = player.Character or player.CharacterAdded:Wait()
                            local vehicle = workspace.Vehicles:FindFirstChild(player.Name)
                            if not vehicle then
                                game.StarterGui:SetCore("SendNotification", {
                                    Title = "Error",
                                    Text = "No vehicle found.",
                                    Duration = 3,
                                })
                                return
                            end

                            local dealers = workspace:FindFirstChild("Dealers")
                            if not dealers then
                                game.StarterGui:SetCore("SendNotification", {
                                    Title = "Error",
                                    Text = "Dealers not found.",
                                    Duration = 3,
                                })
                                tweenTo(SERVER_HOP_SAFE_POSITION)
                                task.wait(1)
                                performServerHop()
                                return
                            end

                            local closest, shortest = nil, math.huge
                            for _, dealer in pairs(dealers:GetChildren()) do
                                if dealer:FindFirstChild("Head") then
                                    local dist = (character.HumanoidRootPart.Position - dealer.Head.Position).Magnitude
                                    if dist < shortest then
                                        shortest = dist
                                        closest = dealer.Head
                                    end
                                end
                            end

                            if not closest then
                                game.StarterGui:SetCore("SendNotification", {
                                    Title = "Error",
                                    Text = "No dealer found.",
                                    Duration = 3,
                                })
                                tweenTo(SERVER_HOP_SAFE_POSITION)
                                task.wait(1)
                                performServerHop()
                                return
                            end

                            local destination1 = closest.Position + Vector3.new(0, 2.5, 0)
                            lyphixDealerApproachActive = true
                            pcall(tweenTo, destination1)
                            lyphixDealerApproachActive = false
                        end

                        -- Ein einziger Dealer-Stopp: optional komplett verkaufen + N Bomben kaufen (laut geplant offene Raubzüge)
                        local function performSingleDealerTrip(bombsToPurchase, includeSell)
                            if bombsToPurchase < 0 then
                                bombsToPurchase = 0
                            end
                            if bombsToPurchase == 0 and not includeSell then
                                return false
                            end
                            local startBombs = countBombsInInventory()
                            local targetBombs = startBombs + bombsToPurchase
                            ensurePlayerInVehicle()
                            MoveToDealer()
                            task.wait(0.5)
                            if includeSell then
                                local argsSell = { [1] = "Gold", [2] = "Dealer" }
                                sellRemoteEvent:FireServer(unpack(argsSell))
                                sellRemoteEvent:FireServer(unpack(argsSell))
                                sellRemoteEvent:FireServer(unpack(argsSell))
                                task.wait(0.5)
                            end
                            if bombsToPurchase > 0 then
                                local argsBuy = { [1] = "Bomb", [2] = "Dealer" }
                                for _ = 1, bombsToPurchase do
                                    buyRemoteEvent:FireServer(unpack(argsBuy))
                                    recordBombPurchase()
                                    task.wait(0.45)
                                end
                                local deadline = os.clock() + 10
                                while countBombsInInventory() < targetBombs and os.clock() < deadline do
                                    task.wait(0.08)
                                end
                            end
                            task.wait(0.2)
                            return true
                        end

                        local function robBankAndClub()
                            if isServerHopping then
                                return
                            end
                            local player = game.Players.LocalPlayer
                            local character = player.Character or player.CharacterAdded:Wait()

                            -- Kein dauerhaftes Kamera-Lock (Heartbeat): das blockiert Fahrzeug-/Tween-Kamera und bricht Bewegung
                            local cam = workspace.CurrentCamera
                            if cam then
                                cam.CameraType = Enum.CameraType.Custom
                            end

                            local clubPos = Vector3.new(-1739.5330810546875, 11, 3052.31103515625)
                            local clubStand = Vector3.new(-1744.177001953125, 11.125, 3012.20263671875)
                            local clubSafe = Vector3.new(-1743.4300537109375, 11.124999046325684, 3049.96630859375)

                            ensurePlayerInVehicle()
                            task.wait(0.5)
                            clickAtCoordinates(0.5, 0.9)
                            task.wait(0.5)
                            tweenTo(Vector3.new(-1370.972412109375, 5.499999046325684, 3127.154541015625))
                            task.wait(0.5)

                            local clubPart = workspace.Robberies["Club Robbery"].Club.Door.Accessory.Black
                            local bankPart = workspace.Robberies.BankRobbery.VaultDoor["Meshes/Tresor_Plane (2)"]
                            local bankLight = workspace.Robberies.BankRobbery.LightGreen.Light
                            local bankLight2 = workspace.Robberies.BankRobbery.LightRed.Light
                            local JewelerPart = workspace.Robberies["Jeweler Safe Robbery"].Jeweler.Door.Accessory.Black

                            local clubOpenAtPlan = clubPart.Rotation == Vector3.new(180, 0, 180)
                            local bankOpenAtPlan = bankLight2.Enabled == false and bankLight.Enabled == true
                            local jewelerOpenAtPlan = (robMode == "Rob Club, Jeweler & Bank") and JewelerPart.Rotation == Vector3.new(0, -90, 0)
                            local plannedBombRobberies = (clubOpenAtPlan and 1 or 0) + (bankOpenAtPlan and 1 or 0) + (jewelerOpenAtPlan and 1 or 0)
                            local bombsHeld = countBombsInInventory()
                            local bombsToBuyNow = math.max(0, plannedBombRobberies - bombsHeld)
                            if autoSellToggle or bombsToBuyNow > 0 then
                                performSingleDealerTrip(bombsToBuyNow, autoSellToggle)
                                ensurePlayerInVehicle()
                                tweenTo(Vector3.new(-1370.972412109375, 5.499999046325684, 3127.154541015625))
                            end

                            ensurePlayerInVehicle()
                            tweenTo(Vector3.new(-1370.972412109375, 5.499999046325684, 3127.154541015625))

                            if clubPart.Rotation == Vector3.new(180, 0, 180) then
                                clickAtCoordinates(0.5, 0.9)
                                game.StarterGui:SetCore("SendNotification", {
                                    Title = "Safe is open",
                                    Text = "Going to rob",
                                })

                                ensurePlayerInVehicle()
                                tweenTo(clubPos)
                                task.wait(0.5)
                                JumpOut()
                                task.wait(0.5)

                                plrTween(Vector3.new(-1744.177001953125, 11.125, 3017.20263671875))
                                task.wait(0.5)

                                runBombThrowSequence()

                                plrTween(clubSafe)
                                task.wait(2.7)
                                plrTween(clubStand)

                                startPoliceMonitoring("Club")

                                local safeFolder = workspace.Robberies["Club Robbery"].Club
                                lootSafeUntilClear(safeFolder:FindFirstChild("Items"), safeFolder:FindFirstChild("Money"), false)
                                task.wait(0.5)

                                stopPoliceMonitoring()
                                ensurePlayerInVehicle()
                                tweenTo(Vector3.new(-1370.972412109375, 5.499999046325684, 3127.154541015625))
                            else
                                game.StarterGui:SetCore("SendNotification", {
                                    Title = "Safe is not open",
                                    Text = "Going to bank",
                                })
                                ensurePlayerInVehicle()
                                tweenTo(Vector3.new(-1370.972412109375, 5.499999046325684, 3127.154541015625))
                            end

                            if bankLight2.Enabled == false and bankLight.Enabled == true then
                                clickAtCoordinates(0.5, 0.9)
                                game.StarterGui:SetCore("SendNotification", {
                                    Title = "Bank is open",
                                    Text = "Going to rob",
                                })

                                tweenTo(Vector3.new(-1202.86181640625, 7.877995491027832, 3164.614501953125))
                                tweenTo(Vector3.new(-1202.86181640625, 7.877995491027832, 3164.614501953125))
                                JumpOut()
                                task.wait(0.5)
                                plrTween(Vector3.new(-1242.367919921875, 7.749999046325684, 3144.705322265625))
                                task.wait(0.5)
                                runBombThrowSequence()
                                plrTween(Vector3.new(-1239.36669921875, 7.7235002517700195, 3114.240966796875))
                                
                                startPoliceMonitoring("Bank")
                                
                                task.wait(2.5)
                                local safeFolder = workspace.Robberies.BankRobbery
                                plrTween(Vector3.new(-1249.6793212890625, 7.7235636711120605, 3121.9423828125))
                                task.wait(6)
                                plrTween(Vector3.new(-1231.2696533203125, 7.7235002517700195, 3123.935546875))
                                task.wait(6)
                                plrTween(Vector3.new(-1246.9879150390625, 7.7235002517700195, 3103.03955078125))
                                task.wait(6)
                                plrTween(Vector3.new(-1235.13720703125, 7.7235002517700195, 3103.102783203125))
                                
                                stopPoliceMonitoring()
                                task.wait(6)
                                ensurePlayerInVehicle()
                                tweenTo(Vector3.new(-1143.7784423828125, 5.724719047546387, 3457.9404296875))
                            else
                                game.StarterGui:SetCore("SendNotification", {
                                    Title = "Bank is not open",
                                    Text = "Going to jeweler",
                                })
                                ensurePlayerInVehicle()
                                tweenTo(Vector3.new(-1143.7784423828125, 5.724719047546387, 3457.9404296875))
                            end

                            local JewelerPos = Vector3.new(-426.5001220703125, 21.522781372070312, 3576.979248046875)
                            local JewelerStand = Vector3.new(-439.0592041015625, 21.223413467407227, 3553.52783203125)
                            local JewelerSafe = Vector3.new(-407.1869201660156, 21.223413467407227, 3551.096435546875)

                            if robMode == "Rob Club, Jeweler & Bank" then
                                if JewelerPart.Rotation == Vector3.new(0, -90, 0) then
                                    game.StarterGui:SetCore("SendNotification", {
                                        Title = "Jeweler Safe is open",
                                        Text = "Going to rob",
                                    })

                                    ensurePlayerInVehicle()
                                    tweenTo(JewelerPos)
                                    task.wait(0.5)
                                    JumpOut()
                                    task.wait(0.5)

                                    plrTween(Vector3.new(-437.28814697265625, 21.223413467407227, 3553.262939453125))
                                    task.wait(0.5)

                                    runBombThrowSequence()

                                    plrTween(JewelerSafe)
                                    task.wait(2.7)
                                    plrTween(JewelerStand)

                                    startPoliceMonitoring("Jeweler")

                                    local safeFolder = workspace.Robberies["Jeweler Safe Robbery"].Jeweler
                                    lootSafeUntilClear(safeFolder:FindFirstChild("Items"), safeFolder:FindFirstChild("Money"), false)
                                    
                                    stopPoliceMonitoring()
                                    task.wait(0.5)

                                    ensurePlayerInVehicle()
                                    tweenTo(SERVER_HOP_SAFE_POSITION)
                                    task.wait(1)
                                    performServerHop()
                                else
                                    game.StarterGui:SetCore("SendNotification", {
                                        Title = "Jeweler Safe is not open",
                                        Text = "Going to server hop",
                                    })
                                    tweenTo(SERVER_HOP_SAFE_POSITION)
                                    task.wait(1)
                                    performServerHop()
                                end
                            else
                                game.StarterGui:SetCore("SendNotification", {
                                    Title = "Mode: Club & Bank",
                                    Text = "Skipping Jeweler → Server Hop",
                                })
                                tweenTo(SERVER_HOP_SAFE_POSITION)
                                task.wait(1)
                                performServerHop()
                            end
                        end

                        local function robContainers()
                            if isServerHopping then
                                return
                            end
                            tweenTo(Vector3.new(1058.7470703125, 5.733738899230957, 2218.6943359375))
                            task.wait(0.5)

                            local robberies = workspace:FindFirstChild("Robberies")
                            local containerFolder = robberies and robberies:FindFirstChild("ContainerRobberies")
                            if not containerFolder then
                                warn("[robContainers] ContainerRobberies missing")
                                return
                            end

                            local containers = {}

                            local function getContainerRobberies(folder)
                                local result = {}
                                if not folder then
                                    return result
                                end
                                for _, model in ipairs(folder:GetChildren()) do
                                    if model.Name == "ContainerRobbery" then
                                        table.insert(result, model)
                                    end
                                end
                                return result
                            end

                            containers = getContainerRobberies(containerFolder)

                            local container1 = containers[1]
                            local container2 = containers[2]
                            if not container1 or not container2 then
                                warn("[robContainers] need 2 ContainerRobbery models, got " .. tostring(#containers))
                                ensurePlayerInVehicle()
                                tweenTo(Vector3.new(1656.3526611328125, -25.936052322387695, 2821.137451171875))
                                performServerHop()
                                return
                            end

                            local con1Planks = container1:FindFirstChild("WoodPlanks", true)
                            local con2Planks = container2:FindFirstChild("WoodPlanks", true)
                            if not con1Planks or not con2Planks then
                                warn("[robContainers] WoodPlanks missing on container(s)")
                                ensurePlayerInVehicle()
                                tweenTo(Vector3.new(1656.3526611328125, -25.936052322387695, 2821.137451171875))
                                performServerHop()
                                return
                            end

                            local con1OpenAtPlan = con1Planks.Transparency == 1
                            local con2OpenAtPlan = con2Planks.Transparency == 1
                            local containerBombJobs = (con1OpenAtPlan and 1 or 0) + (con2OpenAtPlan and 1 or 0)
                            local contBombsHeld = countBombsInInventory()
                            local contBombsToBuy = math.max(0, containerBombJobs - contBombsHeld)
                            if autoSellToggle or contBombsToBuy > 0 then
                                performSingleDealerTrip(contBombsToBuy, autoSellToggle)
                                ensurePlayerInVehicle()
                                tweenTo(Vector3.new(1058.7470703125, 5.733738899230957, 2218.6943359375))
                            end

                            if con1Planks.Transparency == 1 then
                                ensurePlayerInVehicle()
                                task.wait(0.5)
                                tweenTo(con1Planks.Position)
                                tweenTo(con1Planks.Position)
                                task.wait(0.5)
                                JumpOut()
                                task.wait(0.5)
                                plrTween(con1Planks.Position)
                                task.wait(0.5)
                                runBombThrowSequence()
                                ensurePlayerInVehicle()
                                tweenTo(Vector3.new(1096.401, 57.31, 2226.765))
                                task.wait(2)
                                tweenTo(con1Planks.Position)
                                JumpOut()
                                task.wait(0.5)
                                plrTween(con1Planks.Position)
                                
                                startPoliceMonitoring("Container 1")
                                
                                lootSafeUntilClear(container1:FindFirstChild("Items"), container1:FindFirstChild("Money"), true)
                                
                                stopPoliceMonitoring()
                                task.wait(0.2)
                                ensurePlayerInVehicle()
                                task.wait(0.2)
                                tweenTo(Vector3.new(1096.401, 57.31, 2226.765))
                            else
                                game.StarterGui:SetCore("SendNotification", {
                                    Title = "Container 1 not open",
                                    Text = "Going to Container 2",
                                })
                            end

                            if con2Planks.Transparency == 1 then
                                ensurePlayerInVehicle()
                                task.wait(0.5)
                                tweenTo(con2Planks.Position)
                                task.wait(0.5)
                                JumpOut()
                                task.wait(0.5)
                                plrTween(con2Planks.Position)
                                task.wait(0.5)
                                runBombThrowSequence()
                                ensurePlayerInVehicle()
                                tweenTo(Vector3.new(1096.401, 57.31, 2226.765))
                                task.wait(2)
                                tweenTo(con2Planks.Position)
                                JumpOut()
                                task.wait(0.5)
                                plrTween(con2Planks.Position)
                                
                                startPoliceMonitoring("Container 2")
                                
                                lootSafeUntilClear(container2:FindFirstChild("Items"), container2:FindFirstChild("Money"), true)
                                
                                stopPoliceMonitoring()
                                task.wait(0.5)
                                ensurePlayerInVehicle()
                                tweenTo(Vector3.new(1656.3526611328125, -25.936052322387695, 2821.137451171875))
                                performServerHop()
                            else
                                game.StarterGui:SetCore("SendNotification", {
                                    Title = "Container 2 not open",
                                    Text = "Hopping server :^)",
                                })
                            end

                            ensurePlayerInVehicle()
                            tweenTo(Vector3.new(1656.3526611328125, -25.936052322387695, 2821.137451171875))
                            performServerHop()
                        end

                        OrionLib:Init()

                        local robBankClubBusy = false
                        local robContainersBusy = false
                        local autoCollectBusy = false

                        while task.wait() do
                            if isServerHopping then
                                task.wait(0.5)
                            else
                                if (autorobBankClubToggle or autorobContainersToggle) and not autoCollectBusy then
                                    autoCollectBusy = true
                                    task.spawn(function()
                                        pcall(startAutoCollect)
                                        autoCollectBusy = false
                                    end)
                                end

                                if autorobBankClubToggle == true and not robBankClubBusy and not isServerHopping then
                                    robBankClubBusy = true
                                    task.spawn(function()
                                        pcall(robBankAndClub)
                                        robBankClubBusy = false
                                    end)
                                end

                                if autorobContainersToggle == true and not robContainersBusy and not isServerHopping then
                                    robContainersBusy = true
                                    task.spawn(function()
                                        pcall(robContainers)
                                        robContainersBusy = false
                                    end)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)