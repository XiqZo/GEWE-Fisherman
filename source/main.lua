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
local playerData = {
    playerVelocity = 3,
    playerX = 30,
    playerY = 120,
}

local fishingRod = {
    fishlineSpeedModifer = 1,
    fishlineSpeed = 2
}
-- preparing, casting, reeling, sailing
local gameStates = {
    preparing = "preparing",
    sailing = "sailing",
    casting = "casting",
    reeling = "reeling"
}
local gameState = gameStates.casting

-- Drawing player image
local playerImage = gfx.image.new("assets/fisherman")
local playerSprite = gfx.sprite.new(playerImage)

local reelLength = {
    x0 = 0,
    y0 = 0,
    x1 = 0,
    y1 = 0
}

playerSprite:setScale(0.6)
playerSprite:moveTo(playerData.playerX, playerData.playerY)
playerSprite:add()

local function movePlayer(currentX, currentY)
    if currentY >= 10 and pd.buttonIsPressed(pd.kButtonUp) then
        playerSprite:moveBy(0, -playerData.playerVelocity)
    end
    if currentY <= 230 and pd.buttonIsPressed(pd.kButtonDown) then
        playerSprite:moveBy(0, playerData.playerVelocity)
    end 
end

local function castReel(currentX, currentY)
    reelLength.x0, reelLength.y0, reelLength.x1, reelLength.y1 = currentX+10, currentY, 350, currentY+20
    gfx.drawLine(reelLength.x0, reelLength.y0, reelLength.x1, reelLength.y1)
end
-- playdate.update function is required in every project!
function pd.update()
    gfx.sprite.update()
    gfx.drawLine(55, 0, 55, 240)

    local crankPosition = pd.getCrankPosition()
    local change, acceleratedChange = pd.getCrankChange()
    local currentX, currentY = playerSprite:getPosition()

    if gameState == gameStates.casting then
        movePlayer(currentX, currentY)

        if pd.buttonJustPressed(pd.kButtonA) then
            gameState = gameStates.reeling
        end
        
    elseif gameState == gameStates.reeling then
        castReel(currentX, currentY)
        
        if reelLength.x1 >= reelLength.x0 then
            if change >= 10 and acceleratedChange ~= nil and acceleratedChange >= 20 then
                fishingRod.fishlineSpeedModifer = acceleratedChange
                reelLength.x1 -= fishingRod.fishlineSpeed * fishingRod.fishlineSpeedModifer
            end
        end
    elseif gameState == gameStates.sailing then
        local boatspeed = acceleratedChange
    end
end
