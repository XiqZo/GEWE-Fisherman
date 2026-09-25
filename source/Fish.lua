local pd <const> = playdate
local gfx <const> = pd.graphics

Fish = {}
class("Fish").extends()

function Fish:init()
    self.spawned = false
    self.nextSpawn = nil

    self.sprite = gfx.sprite.new(
        gfx.image.new("assets/fish1")
    )

    self.sprite:setZIndex(5)

end

function Fish:SpawnTimerSetter(time)
    self.nextSpawn = math.random(
        math.ceil(time),
        math.ceil(time) + 6
    )
end

function Fish:MoveFish()
    self.sprite:moveTo(
        math.random(60, 380),
        math.random(20, 220)
    )
end

function Fish:update(time)
    if self.spawned then
        return
    end

    if self.nextSpawn == nil then
        self:SpawnTimerSetter(time)
    end

    if time >= self.nextSpawn then
        self:MoveFish()

        self.sprite:add()
        self.spawned = true
    end

end

function Fish:remove()
        self.spawned = false
        self.nextSpawn = nil
        self.sprite:remove()
    end

    function Fish:checkCollision(hookX, hookY)
        if not self.spawned then
        return false
    end

    local fishX, fishY =
        self.sprite:getPosition()

    local width, height =
        self.sprite:getSize()

    local left = fishX - width / 2
    local right = fishX + width / 2
    local top = fishY - height / 2
    local bottom = fishY + height / 2

    return hookX >= left
        and hookX <= right
        and hookY >= top
    and hookY <= bottom

end
