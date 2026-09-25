local pd <const> = playdate
local gfx <const> = pd.graphics
local menu = pd.getSystemMenu()

SailingScene = {}
class("SailingScene").extends(gfx.sprite)

function SailingScene:init()

    -- Random fish destination
    self.fishX = math.random(20, 380)
    self.fishY = math.random(20, 220)

    -- Create boat
    self.boat = Boat()

    -- Create fish target
    self.fish = gfx.sprite.new(
        gfx.image.new("assets/fish1")
    )

    self.fish:moveTo(
        self.fishX,
        self.fishY
    )

    self.fish:setZIndex(5)
    self.fish:add()

    -- Scene itself
    self:add()

    self.pierMenuItem = menu:addMenuItem(
        "Back to pier",
        function()
            SCENE_MANAGER:switchScene(GameStartScene)
        end
    )

end



function SailingScene:update()

    local change, acceleratedChange =
        pd.getCrankChange()

    -- Arrows choose direction
    self:steer()

    -- Crank moves the boat
    self.boat:update(
        change,
        acceleratedChange
    )

    -- Check if we reached the fish
    self:checkDestination()

end

function SailingScene:steer()

    if pd.buttonIsPressed(pd.kButtonLeft) then
        self.boat:turn(-1)
    end

    if pd.buttonIsPressed(pd.kButtonRight) then
        self.boat:turn(1)
    end

end

function SailingScene:checkDestination()

    local boatX, boatY =
        self.boat:getPosition()

    local distanceX =
        boatX - self.fishX

    local distanceY =
        boatY - self.fishY

    local distance =
        math.sqrt(
            distanceX * distanceX +
            distanceY * distanceY
        )

    if distance < 20 then

        SCENE_MANAGER:switchScene(
            FishingScene
        )

    end

end


function SailingScene:cleanup()

    if self.boat then
        self.boat:remove()
        self.boat = nil
    end

    if self.fish then
        self.fish:remove()
        self.fish = nil
    end

    if self.pierMenuItem then
        pd.getSystemMenu():removeMenuItem(
            self.pierMenuItem
        )
        self.pierMenuItem = nil
    end

    self:remove()

end