local pd <const> = playdate
local gfx <const> = playdate.graphics

Player = {}
class("Player").extends()

function Player:init()
    self.velocity = 3

    self.sprite = gfx.sprite.new(
        gfx.image.new("assets/fisherman")
    )

    self.sprite:setScale(0.6)
    self.sprite:moveTo(30, 120)
    self.sprite:setZIndex(10)
    self.sprite:add()
end

function Player:getPosition()
    return self.sprite:getPosition()
end

function Player:move(directions)
    if directions == nil then
        return
    end

    local x, y = self.sprite:getPosition()

    if directions:find("w", 1, true)
        and y >= 10
        and pd.buttonIsPressed(pd.kButtonUp)
    then
        self.sprite:moveBy(0, -self.velocity)
    end

    if directions:find("s", 1, true)
        and y <= 230
        and pd.buttonIsPressed(pd.kButtonDown)
    then
        self.sprite:moveBy(0, self.velocity)
    end

    if directions:find("a", 1, true)
        and x >= 10
        and pd.buttonIsPressed(pd.kButtonLeft)
    then
        self.sprite:moveBy(-self.velocity, 0)
    end

    if directions:find("d", 1, true)
        and x <= 390
        and pd.buttonIsPressed(pd.kButtonRight)
    then
        self.sprite:moveBy(self.velocity, 0)
    end

    function Player:remove()
        self.sprite:remove()
    end
end