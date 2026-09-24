local pd <const> = playdate
local gfx <const> = playdate.graphics

GameEndScene = {}
class('GameEndScene').extends(gfx.sprite)
 
function GameEndScene:init()
    local caught = GAME_DATA.catchOfTheDay
    local title = caught > 0 and ("Catch of the day: " .. caught) or "Better luck next time!"
 
    local image = gfx.image.new(400, 240)
    gfx.pushContext(image)
        gfx.drawTextAligned(title, 200, 100, kTextAlignment.center)
        gfx.drawTextAligned("Press B to return to the pier", 200, 140, kTextAlignment.center)
    gfx.popContext()
 
    local sprite = gfx.sprite.new(image)
    sprite:moveTo(200, 120)
    sprite:add()
 
    self:add()
end
 
function GameEndScene:update()
    if pd.buttonJustPressed(pd.kButtonB) then
        -- New day: reset the catch and save it
        GAME_DATA.catchOfTheDay = 0
        pd.datastore.write(GAME_DATA)
        SCENE_MANAGER:switchScene(GameStartScene)
    end
end