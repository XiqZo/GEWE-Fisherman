local pd <const> = playdate
local gfx <const> = playdate.graphics

local STATES <const> = {
    casting = "casting",
    chargingCast = "chargingCast",
    reeling = "reeling",
}

FishingScene = {}
class('FishingScene').extends(gfx.sprite)

local function directionAllowed(directions, direction)
    if directions == nil or direction == nil then return end
    if directions:find(direction, 1, true) then
        return true
    end
end

function FishingScene:init()
    -- All state lives on the scene, so a fresh scene = a fresh game
    self.state = STATES.casting
    self.time = 0
    self.playerVelocity = 3
 
    self.reel = {
        speed = 1,
        speedModifier = 1,
        castPower = 0,
        castPowerSpeed = 1.5,
        maxCastPower = 100,
        maxLength = 330,
        length = { x0 = 0, y0 = 0, x1 = 0, y1 = 0 },
    }
 
    self.fish = { spawned = false, nextSpawn = nil }
 
    -- "beach line" separating the player from the water (a 1px wide sprite)
    local shore = gfx.sprite.new(gfx.image.new(1, 240, gfx.kColorBlack))
    shore:moveTo(55, 120)
    shore:add()
 
    self.playerSprite = gfx.sprite.new(gfx.image.new("assets/fisherman"))
    self.playerSprite:setScale(0.6)
    self.playerSprite:moveTo(30, 120)
    self.playerSprite:add()
 
    self.fishSprite = gfx.sprite.new(gfx.image.new("assets/fish1"))
 
    -- Full-screen sprite used to draw the fishing line and power bar.
    -- Drawing straight to the screen inside update() would get wiped by sprite.update().
    self.overlay = gfx.sprite.new()
    self.overlay:setBounds(0, 0, 400, 240)
    self.overlay:setZIndex(100)
    self.overlay:setIgnoresDrawOffset(true)
    self.overlay.draw = function() self:drawOverlay() end
    self.overlay:add()
 
    -- "Back to pier" lives in the system menu (Menu button). Remove it when used,
    -- otherwise it would stay in the menu on the other scenes.
    local menu = pd.getSystemMenu()
    self.pierItem = menu:addMenuItem("Back to pier", function()
        menu:removeMenuItem(self.pierItem)
        SCENE_MANAGER:switchScene(GameStartScene)
    end)
 
    self:add()
end


-- Player -----------------------------------------------------------
function FishingScene:movePlayer(directions)
    local x, y = self.playerSprite:getPosition()
    local v = self.playerVelocity
 
    if directionAllowed(directions, 'w') and y >= 10 and pd.buttonIsPressed(pd.kButtonUp) then
        self.playerSprite:moveBy(0, -v)
    end
    if directionAllowed(directions, 's') and y <= 230 and pd.buttonIsPressed(pd.kButtonDown) then
        self.playerSprite:moveBy(0, v)
    end
    if directionAllowed(directions, 'a') and x >= 10 and pd.buttonIsPressed(pd.kButtonLeft) then
        self.playerSprite:moveBy(-v, 0)
    end
    if directionAllowed(directions, 'd') and x <= 390 and pd.buttonIsPressed(pd.kButtonRight) then
        self.playerSprite:moveBy(v, 0)
    end
end

-- Reel -------------------------------------------------------------

function FishingScene:updateCastPower()
    local reel = self.reel
    if pd.buttonIsPressed(pd.kButtonA) then
        reel.castPower = math.min(reel.castPower + reel.castPowerSpeed, reel.maxCastPower)
    end
end
 
function FishingScene:castReel()
    local x, y = self.playerSprite:getPosition()
    local reel = self.reel
    local len = reel.length
 
    len.x0 = x + 10
    len.y0 = y
    len.x1 = len.x0 + reel.maxLength * (reel.castPower / reel.maxCastPower)
    len.y1 = y + 20
end
 
function FishingScene:updateReel(change, acceleratedChange)
    local reel = self.reel
    if reel.length.x1 <= reel.length.x0 then return end
 
    if change and change > 0 then
        reel.speedModifier = acceleratedChange * 0.06
        reel.length.x1 = reel.length.x1 - (reel.speed * reel.speedModifier)
    end
end

-- Fish -------------------------------------------------------------

function FishingScene:spawnFish()
    local fish = self.fish
    if fish.spawned then return end
 
    if fish.nextSpawn == nil then
        fish.nextSpawn = math.random(math.ceil(self.time), math.ceil(self.time) + 5)
    end
 
    if self.time >= fish.nextSpawn then
        self.fishSprite:moveTo(math.random(60, 380), math.random(0, 220))
        self.fishSprite:add()
        fish.spawned = true
    end
end
 
function FishingScene:removeFish()
    self.fish.spawned = false
    self.fish.nextSpawn = nil
    self.fishSprite:remove()
end
 
function FishingScene:checkFishCollision()
    if not self.fish.spawned then return false end
 
    local hookX, hookY = self.reel.length.x1, self.reel.length.y1
    local fishX, fishY = self.fishSprite:getPosition()
    local w, h = self.fishSprite:getSize()
 
    return hookX >= fishX - w / 2 and hookX <= fishX + w / 2
       and hookY >= fishY - h / 2 and hookY <= fishY + h / 2
end

-- Drawing ----------------------------------------------------------

function FishingScene:drawOverlay()
    local reel = self.reel
 
    if self.state == STATES.reeling then
        local l = reel.length
        gfx.setColor(gfx.kColorBlack)
        gfx.drawLine(l.x0, l.y0, l.x1, l.y1)
 
    elseif self.state == STATES.chargingCast then
        local barX, barY, barW, barH = 100, 220, 200, 10
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRect(barX, barY, barW, barH)
        gfx.setColor(gfx.kColorBlack)
        gfx.fillRect(barX, barY, barW * (reel.castPower / reel.maxCastPower), barH)
        gfx.drawRect(barX, barY, barW, barH)
    end
end

-- Main loop (called automatically by gfx.sprite.update()) ----------

function FishingScene:update()
    self.time += 1 / 30
    local change, acceleratedChange = pd.getCrankChange()
 
    if self.state == STATES.casting then
        self:movePlayer('ws')
        self:spawnFish()
 
        if pd.buttonJustPressed(pd.kButtonA) then
            self.reel.castPower = 0
            self.state = STATES.chargingCast
        end
 
    elseif self.state == STATES.chargingCast then
        self:updateCastPower()
 
        if pd.buttonJustReleased(pd.kButtonA) then
            self:castReel()
            self.state = STATES.reeling
        end
 
    elseif self.state == STATES.reeling then
        self:updateReel(change, acceleratedChange)
 
        if self:checkFishCollision() then
            GAME_DATA.catchOfTheDay += 1
            self:removeFish()
            self.state = STATES.casting
        elseif self.reel.length.x1 <= self.reel.length.x0 then
            self.state = STATES.casting
        end
    end
 
    self.overlay:markDirty() -- redraw the line/bar every frame
end