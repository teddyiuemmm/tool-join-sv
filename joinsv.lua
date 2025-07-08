local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local historyFile = "lichsu_teleport.txt"
local history = {}

-- Cấu hình Discord Webhook (thay URL này bằng webhook của bạn)
local DISCORD_WEBHOOK_URL = "https://discord.com/api/webhooks/1324251391174250627/Wo9JqpEhGS0EvlMMwavnTx9sT_g3FcRu_fVc0oLvzEYKEbeNImYsJRPxBQOvi8I53Zs4"

-- Load lịch sử từ file
if isfile and readfile and isfile(historyFile) then
    local content = readfile(historyFile)
    for line in string.gmatch(content, "[^\r\n]+") do
        table.insert(history, line)
    end
end

-- GUI chính
local ScreenGui = Instance.new("ScreenGui", Players.LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.Name = "TeleportMenu"
ScreenGui.ResetOnSpawn = false

local ToggleButton = Instance.new("TextButton", ScreenGui)
ToggleButton.Size = UDim2.new(0, 100, 0, 30)
ToggleButton.Position = UDim2.new(0, 20, 0, 20)
ToggleButton.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 14
ToggleButton.Text = "ON/OFF"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 420, 0, 300)
Frame.Position = UDim2.new(0.5, -210, 0.5, -150)
Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Frame.BorderSizePixel = 0
Frame.Visible = false
Frame.Active = true

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "Teleport Menu - by Wxrdead (Enhanced)"
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14

local TextBox = Instance.new("TextBox", Frame)
TextBox.PlaceholderText = "Nhập link game, ID hoặc link server VIP/LaunchData..." -- Chữ mờ gợi ý
TextBox.Size = UDim2.new(0.9, 0, 0, 30)
TextBox.Position = UDim2.new(0.05, 0, 0.15, 0)
TextBox.ClearTextOnFocus = false
TextBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TextBox.Font = Enum.Font.Gotham
TextBox.TextSize = 14
TextBox.Text = ""

local JoinButton = Instance.new("TextButton", Frame)
JoinButton.Text = "Join Game"
JoinButton.Size = UDim2.new(0.9, 0, 0, 30)
JoinButton.Position = UDim2.new(0.05, 0, 0.3, 0)
JoinButton.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
JoinButton.TextColor3 = Color3.fromRGB(255, 255, 255)
JoinButton.Font = Enum.Font.GothamBold
JoinButton.TextSize = 14

local ClearAllButton = Instance.new("TextButton", Frame)
ClearAllButton.Text = "Xóa toàn bộ lịch sử"
ClearAllButton.Size = UDim2.new(0.9, 0, 0, 25)
ClearAllButton.Position = UDim2.new(0.05, 0, 0.42, 0)
ClearAllButton.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
ClearAllButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ClearAllButton.Font = Enum.Font.GothamBold
ClearAllButton.TextSize = 12

local HistoryList = Instance.new("ScrollingFrame", Frame)
HistoryList.Size = UDim2.new(0.9, 0, 0.4, 0)
HistoryList.Position = UDim2.new(0.05, 0, 0.53, 0)
HistoryList.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
HistoryList.CanvasSize = UDim2.new(0, 0, 0, 0)
HistoryList.ScrollBarThickness = 6

local UIListLayout = Instance.new("UIListLayout", HistoryList)
UIListLayout.Padding = UDim.new(0, 2)

-- Lưu toàn bộ lịch sử
local function saveHistory()
    if writefile then
        local content = table.concat(history, "\n")
        writefile(historyFile, content)
    end
end

-- Làm mới danh sách hiển thị
local function refreshHistory()
    HistoryList:ClearAllChildren()
    for i, link in ipairs(history) do
        local holder = Instance.new("Frame", HistoryList)
        holder.Size = UDim2.new(1, 0, 0, 25)
        holder.BackgroundTransparency = 1

        local btn = Instance.new("TextButton", holder)
        btn.Size = UDim2.new(0.8, -5, 1, 0)
        btn.Position = UDim2.new(0, 0, 0, 0)
        btn.Text = link
        btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 12
        btn.MouseButton1Click:Connect(function()
            TextBox.Text = link
        end)

        local del = Instance.new("TextButton", holder)
        del.Size = UDim2.new(0.2, 0, 1, 0)
        del.Position = UDim2.new(0.8, 5, 0, 0)
        del.Text = "Xóa"
        del.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
        del.TextColor3 = Color3.fromRGB(255, 255, 255)
        del.Font = Enum.Font.Gotham
        del.TextSize = 12
        del.MouseButton1Click:Connect(function()
            table.remove(history, i)
            refreshHistory()
            saveHistory()
        end)
    end
    HistoryList.CanvasSize = UDim2.new(0, 0, 0, #history * 27)
end

refreshHistory()

-- Gửi webhook Discord
local function sendDiscordWebhook(placeId, launchData, vipServerId, gameTitle)
    if DISCORD_WEBHOOK_URL == "" or DISCORD_WEBHOOK_URL == "https://discord.com/api/webhooks/YOUR_WEBHOOK_URL_HERE" then
        print("Webhook chưa được cấu hình!")
        return
    end
    
    local player = Players.LocalPlayer
    local currentTime = os.date("%Y-%m-%d %H:%M:%S")
    
    local embedData = {
        ["embeds"] = {{
            ["title"] = "🎮 Roblox Game Join Log",
            ["color"] = 3447003,
            ["fields"] = {
                {
                    ["name"] = "👤 Player Info",
                    ["value"] = string.format("**Name:** %s\n**Display Name:** %s\n**User ID:** %d", 
                        player.Name, player.DisplayName, player.UserId),
                    ["inline"] = true
                },
                {
                    ["name"] = "🎯 Game Info",
                    ["value"] = string.format("**Place ID:** %s\n**Game Title:** %s", 
                        tostring(placeId), gameTitle or "Loading..."),
                    ["inline"] = true
                },
                {
                    ["name"] = "⚙️ Connection Details",
                    ["value"] = string.format("**VIP Server:** %s\n**Launch Data:** %s\n**Time:** %s", 
                        vipServerId and "Yes" or "No", 
                        launchData and "Yes" or "No", 
                        currentTime),
                    ["inline"] = false
                }
            },
            ["footer"] = {
                ["text"] = "Teleport Menu by Wxrdead"
            },
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    }
    
    local success, response = pcall(function()
        return HttpService:PostAsync(DISCORD_WEBHOOK_URL, HttpService:JSONEncode(embedData), Enum.HttpContentType.ApplicationJson)
    end)
    
    if not success then
        warn("Failed to send Discord webhook: " .. tostring(response))
    end
end

-- Lấy thông tin game từ Place ID
local function getGameInfo(placeId)
    local success, response = pcall(function()
        return HttpService:GetAsync("https://games.roblox.com/v1/games?universeIds=" .. tostring(placeId))
    end)
    
    if success then
        local data = HttpService:JSONDecode(response)
        if data and data.data and data.data[1] then
            return data.data[1].name
        end
    end
    return "Unknown Game"
end

-- Phân tích link (cải tiến)
local function parseInput(inputText)
    local placeId, vipServerId, launchData
    inputText = tostring(inputText)

    -- Phân tích link có launchData
    local launchDataPattern = "placeId=(%d+).*launchData=([%w_-]+)"
    placeId, launchData = string.match(inputText, launchDataPattern)
    
    if not placeId then
        -- Phân tích link VIP server
        local linkVipPattern = "roblox%.com/games/(%d+)/.-%?privateServerLinkCode=([%w_-]+)"
        placeId, vipServerId = string.match(inputText, linkVipPattern)
    end

    if not placeId then
        -- Phân tích link game thông thường
        placeId = string.match(inputText, "roblox%.com/games/(%d+)")
    end

    if not placeId then
        -- Phân tích link game tiếng Việt
        placeId = string.match(inputText, "roblox%.com/vi/games/(%d+)")
    end

    if not placeId and tonumber(inputText) then
        -- Nếu chỉ là số ID
        placeId = inputText
    end

    return tonumber(placeId), vipServerId, launchData
end

-- Nút Join Game
JoinButton.MouseButton1Click:Connect(function()
    local text = TextBox.Text
    local placeId, vipServerId, launchData = parseInput(text)

    if placeId then
        local exists = false
        for _, v in ipairs(history) do
            if v == text then exists = true break end
        end
        if not exists then
            table.insert(history, text)
            refreshHistory()
            saveHistory()
        end

        -- Lấy thông tin game và gửi webhook
        local gameTitle = getGameInfo(placeId)
        sendDiscordWebhook(placeId, launchData, vipServerId, gameTitle)

        -- Teleport based on type
        if vipServerId then
            TeleportService:TeleportToPrivateServer(placeId, vipServerId, Players.LocalPlayer)
        elseif launchData then
            -- Teleport với launch data
            local teleportOptions = Instance.new("TeleportOptions")
            teleportOptions.ServerInstanceId = launchData
            TeleportService:TeleportAsync(placeId, {Players.LocalPlayer}, teleportOptions)
        else
            TeleportService:Teleport(placeId, Players.LocalPlayer)
        end
    else
        warn("Link hoặc ID không hợp lệ!")
    end
end)

-- Xóa toàn bộ lịch sử
ClearAllButton.MouseButton1Click:Connect(function()
    history = {}
    refreshHistory()
    saveHistory()
end)

-- Kéo thả menu
local dragging = false
local dragStart, startPos

Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Frame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

ToggleButton.MouseButton1Click:Connect(function()
    Frame.Visible = not Frame.Visible
end)
