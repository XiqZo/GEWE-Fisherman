import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/easing"
import "CoreLibs/ui"

import "sceneManager"
import "gameStartScene"
import "fishingScene"
import "gameEndScene"

local pd <const> = playdate
local gfx <const> = pd.graphics
 
pd.display.setRefreshRate(30)

-- Data that outlives scenes AND app restarts (loaded from disk if it exists)
GAME_DATA = pd.datastore.read() or {}
GAME_DATA.catchOfTheDay = GAME_DATA.catchOfTheDay or 0  -- fill in defaults for missing/old saves

local function saveGame()
    pd.datastore.write(GAME_DATA)
end

function pd.gameWillTerminate() saveGame() end  -- player exits via the Home menu
function pd.deviceWillSleep() saveGame() end


SCENE_MANAGER = SceneManager()
GameStartScene()


function pd.update()
    gfx.sprite.update()      -- calls update() on every scene (they're sprites) and draws
    pd.timer.updateTimers()  -- REQUIRED, otherwise the wipe transition never finishes
end

-- -- Defining player variables
-- local playerData = {
--     image = gfx.image.new("assets/fisherman"),
--     velocity = 3,
--     scale = 0.6,
--     posX = 30,
--     posY = 120
-- }

-- local fishingRod = {
--     reel = {
--         speed = 1,
--         speedModifier = 1,
--         castPower = 0,
--         castPowerSpeed = 1.5,
--         maxCastPower = 100,
--         maxLength = 330,
--         minLength = 30,
--         length = {
--             x0 = 0,
--             y0 = 0,
--             x1 = 0,
--             y1 = 0
--         }
--     }
-- }
-- -- preparing, casting, reeling, sailing
-- local gameStates = {
--     preparing = "preparing",
--     sailing = "sailing",
--     casting = "casting",
--     chargingCast = "chargingCast",
--     reeling = "reeling"
-- }
-- local gameState = gameStates.casting

-- -- Drawing player image

-- local fishData = {
--     image = gfx.image.new("assets/fish1"),
--     released = false,
--     spawned = false,
--     nextSpawn = nil,
--     scale = 1,
--     velocity = 3,
--     posX = 0,
--     posY = 0
-- }

-- local function updateTimer()
--     local increment = 1/30
--     globalTimer = globalTimer + increment
-- end

-- local function directionAllowed(directions, direction)
--     if directions == nil or direction == nil then return end
--     if directions:find(direction, 1, true) then
--         return true
--     end
-- end

-- local function updateCastPower()
--     local reel = fishingRod.reel

--     if pd.buttonIsPressed(pd.kButtonA) then
--         reel.castPower += reel.castPowerSpeed

--         if reel.castPower > reel.maxCastPower then
--             reel.castPower = reel.maxCastPower
--         end
--     end
-- end


-- local function drawCastPower()
--     local reel = fishingRod.reel

--     local barX = 100
--     local barY = 220
--     local barWidth = 200
--     local barHeight = 10

--     -- Background
--     gfx.setColor(gfx.kColorWhite)
--     gfx.fillRect(barX, barY, barWidth, barHeight)

--     -- Filled portion
--     gfx.setColor(gfx.kColorBlack)

--     local fillWidth = barWidth * (reel.castPower / reel.maxCastPower)

--     gfx.fillRect(barX, barY, fillWidth, barHeight)

--     -- Border
--     gfx.setColor(gfx.kColorBlack)
--     gfx.drawRect(barX, barY, barWidth, barHeight)
-- end

-- local function drawSprite(data, sprite)
--     sprite:setScale(data.scale)
--     sprite:moveTo(data.posX, data.posY)
--     sprite:add()
-- end

-- local playerSprite = gfx.sprite.new(playerData.image)
-- local fishSprite = gfx.sprite.new(fishData.image)

-- drawSprite(playerData, playerSprite)


-- local function movePlayer(directions)
--     if directions == nil then return end
--     local currentX, currentY = playerSprite:getPosition()

--     if directionAllowed(directions, 'w') and currentY >= 10 and pd.buttonIsPressed(pd.kButtonUp) then
--         playerSprite:moveBy(0, -playerData.velocity)
--     end
--     if directionAllowed(directions, 's') and currentY <= 230 and pd.buttonIsPressed(pd.kButtonDown) then
--         playerSprite:moveBy(0, playerData.velocity)
--     end 
--     if directionAllowed(directions, 'a') and currentX >= 10 and pd.buttonIsPressed(pd.kButtonLeft) then
--         playerSprite:moveBy(-playerData.velocity, 0)
--     end 
--     if directionAllowed(directions, 'd') and currentX <= 390 and pd.buttonIsPressed(pd.kButtonRight) then
--         playerSprite:moveBy(playerData.velocity, 0)
--     end 
-- end

-- local function drawReel()
--     gfx.drawLine(fishingRod.reel.length.x0, fishingRod.reel.length.y0, fishingRod.reel.length.x1, fishingRod.reel.length.y1)
-- end

-- local function castReel()
--     local currentX, currentY = playerSprite:getPosition()
--     local reel = fishingRod.reel

--     reel.length.x0 = currentX + 10
--     reel.length.y0 = currentY

--     local castPercentage = reel.castPower / reel.maxCastPower

--     local castLength = reel.maxLength * castPercentage

--     reel.length.x1 = reel.length.x0 + castLength
--     reel.length.y1 = currentY + 20
-- end

-- local function updateReel(change, acceleratedChange)
--     local reel = fishingRod.reel
--     if reel.length.x1 <= reel.length.x0 then return end

--     if change and change > 0 then
--         reel.speedModifier = acceleratedChange * 0.06
--         reel.length.x1 = reel.length.x1 - (reel.speed * reel.speedModifier)
--     end

--     drawReel()

-- end

-- local function fishCreator()
--     if fishData.spawned then return end

--     if fishData.nextSpawn == nil then
--         fishData.nextSpawn = math.random(math.ceil(globalTimer), math.ceil(globalTimer)+5)
--     end

--     if globalTimer >= fishData.nextSpawn then
--     fishData.posX = math.random(60, 380)
--     fishData.posY = math.random(0, 220)

--         drawSprite(fishData, fishSprite)
--         fishData.spawned = true
--     end
-- end

-- local function checkFishCollision()
--     if not fishData.spawned then
--         return false
--     end

--     local reel = fishingRod.reel

--     local hookX = reel.length.x1
--     local hookY = reel.length.y1

--     local fishX, fishY = fishSprite:getPosition()

--     local fishWidth, fishHeight = fishSprite:getSize()

--     local fishLeft = fishX - fishWidth / 2
--     local fishRight = fishX + fishWidth / 2
--     local fishTop = fishY - fishHeight / 2
--     local fishBottom = fishY + fishHeight / 2

--     if hookX >= fishLeft and
--        hookX <= fishRight and
--        hookY >= fishTop and
--        hookY <= fishBottom then

--         return true
--     end

--     return false
-- end

-- -- playdate.update function is required in every project!
-- function pd.update()
--     updateTimer()
--     gfx.sprite.update()
--     -- gfx.drawLine(55, 0, 55, 240)

--     local crankPosition = pd.getCrankPosition()
--     local crankChange, crankAcceleratedChange = pd.getCrankChange()

--     if gameState == gameStates.casting then
--         movePlayer('ws')
--         fishCreator()

--         if pd.buttonJustPressed(pd.kButtonA) then
--             fishingRod.reel.castPower = 0
--             gameState = gameStates.chargingCast
--         end

--     elseif gameState == gameStates.chargingCast then
--         updateCastPower()
--         drawCastPower()

--         if pd.buttonJustReleased(pd.kButtonA) then
--             castReel()
--             gameState = gameStates.reeling
--         end

--     elseif gameState == gameStates.reeling then
--         updateReel(crankChange, crankAcceleratedChange)

--         if checkFishCollision() then
--             print("FISH CAUGHT!")

--             fishData.released = false
--             fishData.spawned = false
--             fishData.nextSpawn = nil

--             fishSprite:remove()

--             gameState = gameStates.casting

--         elseif fishingRod.reel.length.x1 <= fishingRod.reel.length.x0 then 
--             gameState = gameStates.casting
--         end
        
--     elseif gameState == gameStates.sailing then
--         local boatspeed = crankAcceleratedChange
--     end
-- end