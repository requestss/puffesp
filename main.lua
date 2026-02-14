local workspace = game:GetService("Workspace")
local puffshrooms = workspace:WaitForChild("Happenings"):WaitForChild("Puffshrooms")

local boxes = {}
local labels = {}

local config = _G.PuffshroomConfig or {
    showNormal = false,
    showRare = true,
    showEpic = true,
    showLegendary = true,
    showMythic = true,
    showLevel = true
}

local colors = {
    Common = Color3.fromRGB(139, 69, 19),
    Rare = Color3.fromRGB(255, 255, 255),
    Epic = Color3.fromRGB(255, 255, 0),
    Legendary = Color3.fromRGB(0, 112, 255),
    Mythic = Color3.fromRGB(163, 53, 238)
}

local function getRarity(obj)
    local name = obj.Name
    local rarity = "Common"
    local lvl
    
    if name:find("Mythic") then
        rarity = "Mythic"
    elseif name:find("Legendary") then
        rarity = "Legendary"
    elseif name:find("Epic") then
        rarity = "Epic"
    elseif name:find("Rare") then
        rarity = "Rare"
    elseif name:find("Common") then
        rarity = "Common"
    end
    
    local attachment = obj:FindFirstChild("Attachment")
    if attachment then
        local nameRow = attachment:FindFirstChild("NameRow")
        if nameRow then
            local gui = nameRow:FindFirstChild("Gui")
            if gui then
                local label = gui:FindFirstChild("TextLabel")
                if label then
                    local match = label.Text:match("Lvl (%d+)")
                    if match then lvl = tonumber(match) end
                end
            end
        end
    end
    
    return rarity, lvl
end

local function shouldShow(rarity)
    if rarity == "Common" then return config.showNormal end
    if rarity == "Rare" then return config.showRare end
    if rarity == "Epic" then return config.showEpic end
    if rarity == "Legendary" then return config.showLegendary end
    if rarity == "Mythic" then return config.showMythic end
    return false
end

local function addLabel(obj, lvl, col)
    if not config.showLevel or not lvl then return end
    
    local bg = Instance.new("BillboardGui")
    bg.Size = UDim2.new(0, 200, 0, 50)
    bg.StudsOffset = Vector3.new(0, 3, 0)
    bg.AlwaysOnTop = true
    bg.Adornee = obj
    bg.Parent = obj
    
    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.BackgroundTransparency = 1
    txt.Text = "Lvl " .. lvl
    txt.TextColor3 = col
    txt.TextScaled = true
    txt.TextStrokeTransparency = 0.5
    txt.Font = Enum.Font.GothamBold
    txt.Parent = bg
    
    labels[obj] = bg
end

local function highlight(obj)
    if not (obj:IsA("BasePart") or obj:IsA("Model")) then return end
    
    local rarity, lvl = getRarity(obj)
    if not rarity or not shouldShow(rarity) then return end
    
    local col = colors[rarity] or Color3.fromRGB(255, 255, 255)
    
    local box = Instance.new("SelectionBox")
    box.Adornee = obj
    box.Color3 = col
    box.LineThickness = 0.05
    box.Transparency = 0.3
    box.Parent = obj
    
    boxes[obj] = box
    addLabel(obj, lvl, col)
end

local function remove(obj)
    if boxes[obj] then
        boxes[obj]:Destroy()
        boxes[obj] = nil
    end
    if labels[obj] then
        labels[obj]:Destroy()
        labels[obj] = nil
    end
end

for _, obj in pairs(puffshrooms:GetChildren()) do
    highlight(obj)
end

puffshrooms.ChildAdded:Connect(highlight)
puffshrooms.ChildRemoved:Connect(remove)
