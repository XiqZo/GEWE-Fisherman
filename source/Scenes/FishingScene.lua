local pd <const> = playdate
local gfx <const> = pd.graphics
local menu = pd.getSystemMenu()

FishingScene = {}
class("FishingScene").extends(gfx.sprite)

local STATES <const> = {
    casting = "casting",
    chargingCast = "chargingCast",
    reeling = "reeling",
    fightingFish = "fightingFish"
}

function FishingScene:init()
    self.player = Player()
    self.rod = FishingRod()
    self.fish = Fish()

    self.state = STATES.casting
    self.time = 0

    self.reelProgress = 0

    self.minReelSpeed = 1
    self.maxReelSpeed = 10

    self.safeMinReelSpeed = 3
    self.safeMaxReelSpeed = 7

    self.escapeTimer = 0
    self.escapeTime = 2

    self.shore = gfx.sprite.new(
        gfx.image.new(1, 240, gfx.kColorBlack)
    )

    self.shore:moveTo(55, 120)
    self.shore:setZIndex(1)
    self.shore:add()

    self.overlay = gfx.sprite.new()
    self.overlay:setBounds(0, 0, 400, 240)
    self.overlay:setZIndex(100)
    self.overlay:setIgnoresDrawOffset(true)

    self.overlay.draw = function()
        self:drawOverlay()
    end

    self.pierMenuItem = menu:addMenuItem(
        "Back to pier",
        function()
            SCENE_MANAGER:switchScene(GameStartScene)
        end
    )

    self.overlay:add()
    self:add()
end

function FishingScene:update()
    self.time += 1 / 30

    local change, acceleratedChange =
        pd.getCrankChange()

    if self.state == STATES.casting then
        self:castingUpdate()

    elseif self.state == STATES.chargingCast then
        self:chargingUpdate()

    elseif self.state == STATES.reeling then
        self:reelingUpdate(
            change,
            acceleratedChange
        )

    elseif self.state == STATES.fightingFish then
        self:fightingFishUpdate(
            change,
            acceleratedChange
        )
    end

    self.overlay:markDirty()
end

function FishingScene:castingUpdate()
    self.player:move("ws")
    self.fish:update(self.time)

    if pd.buttonJustPressed(pd.kButtonA) then
        self.rod.castPower = 0
        self.state = STATES.chargingCast
    end
end

function FishingScene:chargingUpdate()
    self.rod:updateCastPower()

    if pd.buttonJustReleased(pd.kButtonA) then
        self.rod:cast(self.player)
        self.state = STATES.reeling
    end
end

function FishingScene:reelingUpdate(
    change,
    acceleratedChange
)
    self.rod:update(
        change,
        acceleratedChange
    )

    local hookX, hookY =
        self.rod:getHookPosition()

    if self.fish:checkCollision(
        hookX,
        hookY
    ) then
        self.reelProgress = 0
        self.escapeTimer = 0
        self.state = STATES.fightingFish

    elseif self.rod:isFinished() then
        self.state = STATES.casting
    end
end

function FishingScene:fightingFishUpdate(
    change,
    acceleratedChange
)
    local reelSpeed = math.abs(acceleratedChange * acceleratedChange)

    if reelSpeed >= self.safeMinReelSpeed
        and reelSpeed <= self.safeMaxReelSpeed
    then
        self.reelProgress += 100 / (5 * 30)

        self.escapeTimer -= 5 / 30

        if self.escapeTimer < 0 then
            self.escapeTimer = 0
        end
    else
        self.escapeTimer += 1 / 30
    end

    if self.escapeTimer >= self.escapeTime then
        self.fish:remove()

        self.reelProgress = 0
        self.escapeTimer = 0

        self.state = STATES.casting

        return
    end

    if self.reelProgress >= 100 then
        GAME_DATA.catchOfTheDay += 1

        self.fish:remove()

        self.reelProgress = 0
        self.escapeTimer = 0

        self.state = STATES.casting
    end
end

function FishingScene:drawOverlay()
    if self.state == STATES.reeling then
        self.rod:draw()

    elseif self.state == STATES.chargingCast then
        self:drawCastPower()

    elseif self.state == STATES.fightingFish then
        self:drawFishFight()
    end
end

function FishingScene:drawCastPower()
    local barX = 100
    local barY = 220
    local barWidth = 200
    local barHeight = 10

    gfx.setColor(gfx.kColorWhite)

    gfx.fillRect(
        barX,
        barY,
        barWidth,
        barHeight
    )

    gfx.setColor(gfx.kColorBlack)

    local fillWidth =
        barWidth *
        (self.rod.castPower / self.rod.maxCastPower)

    gfx.fillRect(
        barX,
        barY,
        fillWidth,
        barHeight
    )

    gfx.drawRect(
        barX,
        barY,
        barWidth,
        barHeight
    )
end

function FishingScene:drawFishFight()
    local barX = 100
    local barY = 220
    local barWidth = 200
    local barHeight = 12

    gfx.setColor(gfx.kColorWhite)

    gfx.fillRect(
        barX,
        barY,
        barWidth,
        barHeight
    )

    gfx.setColor(gfx.kColorBlack)

    local fillWidth =
        barWidth *
        (self.reelProgress / 100)

    gfx.fillRect(
        barX,
        barY,
        fillWidth,
        barHeight
    )

    gfx.drawRect(
        barX,
        barY,
        barWidth,
        barHeight
    )

    local warningX = 100
    local warningY = 200
    local warningWidth = 200
    local warningHeight = 8

    gfx.setColor(gfx.kColorWhite)

    gfx.fillRect(
        warningX,
        warningY,
        warningWidth,
        warningHeight
    )

    gfx.setColor(gfx.kColorBlack)

    gfx.drawRect(
        warningX,
        warningY,
        warningWidth,
        warningHeight
    )

    local warningProgress =
        self.escapeTimer / self.escapeTime

    local warningFill =
        warningWidth * warningProgress

    gfx.fillRect(
        warningX,
        warningY,
        warningFill,
        warningHeight
    )
end

function FishingScene:cleanup()
    if self.pierMenuItem then
        pd.getSystemMenu():removeMenuItem(
            self.pierMenuItem
        )

        self.pierMenuItem = nil
    end

    if self.player then
        self.player:remove()
        self.player = nil
    end

    if self.fish then
        self.fish:remove()
        self.fish = nil
    end

    if self.shore then
        self.shore:remove()
        self.shore = nil
    end

    if self.overlay then
        self.overlay:remove()
        self.overlay = nil
    end

    self:remove()
end
