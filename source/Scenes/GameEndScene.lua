local pd <const> = playdate
local gfx <const> = pd.graphics

local GAP <const> = 16        -- space between fish
local MAX_WIDTH <const> = 380 -- the row shrinks to fit this
local ROW_Y <const> = 110     -- vertical centre of the fish row

GameEndScene = {}
class("GameEndScene").extends(gfx.sprite)

-- Draws one image per caught fish type with "x N" underneath.
-- Call while drawing into an image context.
local function drawCatches()
    local caught, sumWidth = {}, 0
    for _, fishType in ipairs(FISH_TYPES) do -- FISH_TYPES order keeps the layout stable
        local count = GAME_DATA.catches[fishType.id]
        if count and count > 0 then
            caught[#caught + 1] = { image = fishType.image, count = count }
            sumWidth += fishType.image:getSize()
        end
    end

    local gaps = GAP * (#caught - 1)
    local scale = math.min(1, (MAX_WIDTH - gaps) / sumWidth)

    -- Scale fish down if the row would be too wide (never scales up)
    local maxHeight = 0
    for _, entry in ipairs(caught) do
        if scale < 1 then entry.image = entry.image:scaledImage(scale) end
        entry.w, entry.h = entry.image:getSize()
        maxHeight = math.max(maxHeight, entry.h)
    end

    local x = (400 - (sumWidth * scale + gaps)) / 2
    for _, entry in ipairs(caught) do
        entry.image:draw(x, ROW_Y - entry.h / 2)
        gfx.drawTextAligned("x" .. entry.count, x + entry.w / 2, ROW_Y + maxHeight / 2 + 6, kTextAlignment.center)
        x += entry.w + GAP
    end
end

function GameEndScene:init()
    local total = getCatchTotal()

    local image = gfx.image.new(400, 240)
    gfx.pushContext(image)
        if total > 0 then
            gfx.drawTextAligned("Catch of the day: " .. total, 200, 20, kTextAlignment.center)
            drawCatches()
        else
            gfx.drawTextAligned("Better luck next time!", 200, 100, kTextAlignment.center)
        end
        gfx.drawTextAligned("Press B to return to the pier", 200, 210, kTextAlignment.center)
    gfx.popContext()

    self.sprite = gfx.sprite.new(image)
    self.sprite:moveTo(200, 120)
    self.sprite:add()

    self:add()
end

function GameEndScene:update()
    if pd.buttonJustPressed(pd.kButtonB) then
        -- New day: reset the catch and save it
        GAME_DATA.catches = {}
        pd.datastore.write(GAME_DATA)
        SCENE_MANAGER:switchScene(GameStartScene)
    end
end

function GameEndScene:cleanup()
    if self.sprite then
        self.sprite:remove()
        self.sprite = nil
    end
    self:remove()
end