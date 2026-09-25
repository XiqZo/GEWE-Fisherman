local pd <const> = playdate
local gfx <const> = playdate.graphics

GameEndScene = {}
class('GameEndScene').extends(gfx.sprite)

function GameEndScene:init()

    local caught = GAME_DATA.catchOfTheDay

    local title

    if caught > 0 then
        title = "Catch of the day: " .. caught
    else
        title = "Better luck next time!"
    end


    -- Text --------------------------------------------------------

    local image = gfx.image.new(400, 240)

    gfx.pushContext(image)

        gfx.drawTextAligned(
            title,
            200,
            100,
            kTextAlignment.center
        )

        gfx.drawTextAligned(
            "Press B to return to the pier",
            200,
            140,
            kTextAlignment.center
        )

    gfx.popContext()


    self.textSprite = gfx.sprite.new(image)
    self.textSprite:moveTo(200, 120)
    self.textSprite:setZIndex(1)
    self.textSprite:add()


    -- Scene itself -----------------------------------------------

    self:add()
end


function GameEndScene:update()

    if pd.buttonJustPressed(pd.kButtonB) then

        GAME_DATA.catchOfTheDay = 0
        SCENE_MANAGER:switchScene(GameStartScene)

    end
end


function GameEndScene:cleanup()

    if self.textSprite then
        self.textSprite:remove()
        self.textSprite = nil
    end

    self:remove()
end
