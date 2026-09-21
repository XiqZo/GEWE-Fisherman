-- Below is a small example program where you can move a circle
-- around with the crank. You can delete everything in this file,
-- but make sure to add back in a playdate.update function since
-- one is required for every Playdate game!
-- =============================================================

-- Importing libraries used for drawCircleAtPoint and crankIndicator
import "CoreLibs/graphics"
import "CoreLibs/ui"

-- Localizing commonly used globals
local pd <const> = playdate
local gfx <const> = pd.graphics

-- Defining player variables
local playerSize = 10
local playerVelocity = 3
local fishlineSpeedModifer = 1
local fishlineSpeed = 2 * fishlineSpeedModifer
local playerX, playerY = 30, 120

local gameState = "casting"

-- Drawing player image
local playerImage = gfx.image.new("assets/fisherman")
local playerSprite = gfx.sprite.new(playerImage)
local x0, y0, x1, y1 = playerX-10, playerY-20, 350, playerY+20
playerSprite:setScale(0.6)
playerSprite:moveTo(playerX, playerY)
playerSprite:add()

local function movePlayer(currentX, currentY)
    if currentY >= 10 and pd.buttonIsPressed(pd.kButtonUp) then
        playerSprite:moveBy(0, -playerVelocity)
    end
    if currentY <= 230 and pd.buttonIsPressed(pd.kButtonDown) then
        playerSprite:moveBy(0, playerVelocity)
    end 
end

-- playdate.update function is required in every project!
function pd.update()
    gfx.sprite.update()
    gfx.drawLine(55, 0, 55, 240)

    local crankPosition = pd.getCrankPosition()
    local change, acceleratedChange = pd.getCrankChange()
    local currentX, currentY = playerSprite:getPosition()

    if gameState == "casting" then
        movePlayer(currentX, currentY)

        if pd.buttonJustPressed(pd.kButtonA) then
            gameState = "reeling"
            x0, y0, x1, y1 = currentX+10, currentY, 350, currentY+20
        end
        
    elseif gameState == "reeling" then
        gfx.drawLine(x0, y0, x1, y1)
        if x1 >= x0 then
            if change >= 10 and acceleratedChange ~= nil and acceleratedChange >= 20 then
                fishlineSpeedModifer = acceleratedChange
                x1 -= fishlineSpeed
            end
        end
    end
end
