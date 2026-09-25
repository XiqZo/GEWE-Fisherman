local pd <const> = playdate
local gfx <const> = pd.graphics

GameStartScene = {}
class('GameStartScene').extends(gfx.sprite)

function GameStartScene:init()

    self.pierSprite = gfx.sprite.new(
        gfx.image.new("assets/catchsomething")
    )

    self.pierSprite:moveTo(200, 120)
    self.pierSprite:setZIndex(0)
    self.pierSprite:add()


    -- Text --------------------------------------------------------

    local textImage = gfx.image.new(400, 240)

    gfx.pushContext(textImage)

        gfx.drawText(
            "Catch so far: " .. getCatchTotal(),
            10,
            10
        )

        gfx.drawText(
            "A: go fishing",
            10,
            200
        )

        gfx.drawText(
            "B: end the day",
            10,
            220
        )

    gfx.popContext()


    self.textSprite = gfx.sprite.new(textImage)
    self.textSprite:moveTo(200, 120)
    self.textSprite:setZIndex(1)
    self.textSprite:add()

    self:add()
end


function GameStartScene:update()

    if pd.buttonJustPressed(pd.kButtonA) then

        SCENE_MANAGER:switchScene(SailingScene)

    elseif pd.buttonJustPressed(pd.kButtonB) then

        SCENE_MANAGER:switchScene(GameEndScene)

    end
end


function GameStartScene:cleanup()

    if self.pierSprite then
        self.pierSprite:remove()
        self.pierSprite = nil
    end

    if self.textSprite then
        self.textSprite:remove()
        self.textSprite = nil
    end

    self:remove()
end