local pd <const> = playdate
local gfx <const> = pd.graphics

Boat = {}
class("Boat").extends()

function Boat:init()

    self.x = 200
    self.y = 210

    self.speed = 1
    self.speedModifier = 1

    -- Boat initially faces up
    self.angle = -90

    -- How quickly left/right turns the boat
    self.turnSpeed = 1

    self.sprite = gfx.sprite.new(
        gfx.image.new("assets/boat")
    )

    self.sprite:setZIndex(5)
    self.sprite:moveTo(self.x, self.y)
    self.sprite:add()

end


function Boat:update(change, acceleratedChange)

    -- Crank = move forward
    if change and change ~= 0 then
        
        self.speedModifier = math.abs(acceleratedChange) * 0.02
        
        if change < 0 then 
            self.speedModifier = -1 * self.speedModifier
        end

        local radians =
            math.rad(self.angle)

        self.x +=
            math.cos(radians) *
            self.speed *
            self.speedModifier

        self.y +=
            math.sin(radians) *
            self.speed *
            self.speedModifier

    end

    -- Keep boat on screen
    if self.x < 20 then
        self.x = 20
    elseif self.x > 380 then
        self.x = 380
    end

    if self.y < 20 then
        self.y = 20
    elseif self.y > 220 then
        self.y = 220
    end

    self.sprite:moveTo(
        self.x,
        self.y
    )

    -- Rotate sprite to match heading
    self.sprite:setRotation(self.angle + 90)

end


function Boat:turn(direction)

    self.angle +=
        direction * self.turnSpeed

end


function Boat:getPosition()

    return self.x, self.y

end


function Boat:remove()

    self.sprite:remove()

end