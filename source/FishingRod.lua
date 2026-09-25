local pd <const> = playdate
local gfx <const> = playdate.graphics

FishingRod = {}
class("FishingRod").extends()

function FishingRod:init()
    self.speed = 1
    self.speedModifier = 1

    self.castPower = 0
    self.castPowerSpeed = 1.5
    self.maxCastPower = 100

    self.maxLength = 330
    self.minLength = 30

    self.length = {
        x0 = 0,
        y0 = 0,
        x1 = 0,
        y1 = 0
    }

end

function FishingRod:updateCastPower()
if pd.buttonIsPressed(pd.kButtonA) then
self.castPower += self.castPowerSpeed

    if self.castPower > self.maxCastPower then
        self.castPower = self.maxCastPower
    end
end

end

function FishingRod:cast(player)
local x, y = player:getPosition()

self.length.x0 = x + 10
self.length.y0 = y

local castPercentage =
    self.castPower / self.maxCastPower

local castLength =
    self.maxLength * castPercentage

self.length.x1 =
    self.length.x0 + castLength

self.length.y1 = y + 20

end

function FishingRod:update(change, acceleratedChange)
if self.length.x1 <= self.length.x0 then
return
end

if change and change > 0 then
    self.speedModifier =
        acceleratedChange * 0.06

    self.length.x1 -=
        self.speed * self.speedModifier
end

end

function FishingRod:isFinished()
return self.length.x1 <= self.length.x0
end

function FishingRod:getHookPosition()
return self.length.x1, self.length.y1
end

function FishingRod:draw()
gfx.setColor(gfx.kColorBlack)

gfx.drawLine(
    self.length.x0,
    self.length.y0,
    self.length.x1,
    self.length.y1
)

end