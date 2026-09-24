local pd <const> = playdate
local gfx <const> = playdate.graphics
 
-- Text positions on screen (400x240). The artwork sits in the middle, so the text
-- goes in the free corners. Tweak these if anything overlaps.
local CATCH_X <const>, CATCH_Y <const> = 10, 10        -- top-left: "Catch so far"
local CONTROLS_X <const>, CONTROLS_Y <const> = 10, 200 -- bottom-left: controls
local LINE_HEIGHT <const> = 20
 
-- The "pier": hub scene where you choose to go fishing or end the day
class('GameStartScene').extends(gfx.sprite)
 
function GameStartScene:init()
    local pierSprite = gfx.sprite.new(gfx.image.new("assets/catchSomething"))
    pierSprite:moveTo(200, 120)
    pierSprite:add()
 
    -- Text is redrawn every time we come back, so the catch count is always current
    local textImage = gfx.image.new(400, 240)
    gfx.pushContext(textImage)
        gfx.drawText("Catch so far: " .. GAME_DATA.catchOfTheDay, CATCH_X, CATCH_Y)
        gfx.drawText("B: go fishing", CONTROLS_X, CONTROLS_Y)
        gfx.drawText("A: end the day", CONTROLS_X, CONTROLS_Y + LINE_HEIGHT)
    gfx.popContext()
 
    local textSprite = gfx.sprite.new(textImage)
    textSprite:moveTo(200, 120)
    textSprite:setZIndex(1)
    textSprite:add()
 
    self:add()
end
 
function GameStartScene:update()
    if pd.buttonJustPressed(pd.kButtonB) then
        SCENE_MANAGER:switchScene(FishingScene)
    elseif pd.buttonJustPressed(pd.kButtonA) then
        SCENE_MANAGER:switchScene(EndScene)
    end
end