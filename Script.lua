local Players = game:GetService("Players")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- =========================================================
-- CONFIGURAÇÃO DA MIRA
-- =========================================================

local WHITE_CROSSHAIR = "rbxassetid://79963539800097"
local TARGET_TOOL_NAME = "Gun"

local ATIVADO = false -- A mira liga sozinha ao pegar a arma


-- =========================================================
-- SHIFT LOCK
-- =========================================================

player.DevEnableMouseLock = true

local function hideShiftLockButton()
    local playerGui = player:FindFirstChildOfClass("PlayerGui")
    if not playerGui then return end

    for _, gui in ipairs(playerGui:GetDescendants()) do
        if gui:IsA("GuiObject") then
            local name = gui.Name:lower()
            if name:find("shift") or name:find("mouse") or name:find("lock") then
                gui.Visible = false
            end
        end
    end
end


-- =========================================================
-- SETINHA "<" DO MM2
-- =========================================================

local function isArrow(obj)
    if obj:IsA("TextLabel") or obj:IsA("TextButton") then
        local text = tostring(obj.Text):gsub("%s+", "")
        return text == "<" or text == ">"
    end
    return false
end

local function hideArrowBox(arrow)
    local parent = arrow.Parent
    for i = 1, 5 do
        if not parent or not parent:IsA("GuiObject") then break end
        local size = parent.AbsoluteSize
        if size.X >= 50 and size.X <= 350 and size.Y >= 50 and size.Y <= 400 then
            parent.Visible = false
            return true
        end
        parent = parent.Parent
    end
    if arrow:IsA("TextButton") then
        arrow.Visible = false
        return true
    end
    return false
end


-- =========================================================
-- MIRA BRANCA — SEM BOTÃO
-- =========================================================

local function atualizarEstado(ativo)
    ATIVADO = ativo
    if ATIVADO then
        mouse.Icon = WHITE_CROSSHAIR
    else
        mouse.Icon = ""
    end
end


-- =========================================================
-- GUN / CROSSHAIR
-- =========================================================

local function monitorarTool(tool)
    if not tool:IsA("Tool") or tool.Name ~= TARGET_TOOL_NAME then return end
    if tool:GetAttribute("CrosshairConectado") then return end
    tool:SetAttribute("CrosshairConectado", true)

    tool.Equipped:Connect(function()
        atualizarEstado(true)
    end)

    tool.Unequipped:Connect(function()
        atualizarEstado(false)
    end)
end


-- =========================================================
-- PERSONAGEM / BACKPACK
-- =========================================================

local function onCharacterAdded(character)
    atualizarEstado(false)

    for _, child in ipairs(character:GetChildren()) do
        monitorarTool(child)
    end
    character.ChildAdded:Connect(monitorarTool)

    local backpack = player:WaitForChild("Backpack")
    for _, tool in ipairs(backpack:GetChildren()) do
        monitorarTool(tool)
    end
    backpack.ChildAdded:Connect(monitorarTool)
end


-- =========================================================
-- INICIALIZAÇÃO
-- =========================================================

if player.Character then
    task.spawn(onCharacterAdded, player.Character)
end
player.CharacterAdded:Connect(onCharacterAdded)


-- =========================================================
-- INTERFACE DO MM2
-- =========================================================

task.wait(3)
hideShiftLockButton()

local playerGui = player:WaitForChild("PlayerGui")
for _, obj in ipairs(playerGui:GetDescendants()) do
    if isArrow(obj) then
        hideArrowBox(obj)
    end
end


-- =========================================================
-- ESCONDE INTERFACE NOVAMENTE SE RECARREGAR
-- =========================================================

playerGui.DescendantAdded:Connect(function(obj)
    task.wait(0.2)

    -- Shift Lock
    if obj:IsA("GuiObject") then
        local name = obj.Name:lower()
        if name:find("shift") or name:find("mouse") or name:find("lock") then
            obj.Visible = false
        end
    end

    -- Seta do MM2
    if isArrow(obj) then
        hideArrowBox(obj)
    end
end)

print("✅ Mira carregada — sem botão na tela!")

