local gfx <const> = playdate.graphics
 
-- One entry per fish. To add a fish: drop its image in assets/ and add a line here.
--   id     unique key, used in the save file (don't rename it later)
--   name   display name (not used yet, handy for a later "fish book")
--   path   image path without .png
--   weight how common it is (higher = more common, default 1)
local definitions = {
    { id = "fish1", name = "Fish 1", path = "assets/fish1", weight = 5 },
    { id = "fish2", name = "Fish 2", path = "assets/fish2", weight = 3 },
    { id = "fish3", name = "Fish 3", path = "assets/fish3", weight = 1 },
}
 
-- Global list, images loaded once at startup
FISH_TYPES = {}
for _, def in ipairs(definitions) do
    local image = gfx.image.new(def.path)
    assert(image, "Missing fish image: " .. def.path)
    FISH_TYPES[#FISH_TYPES + 1] = {
        id = def.id,
        name = def.name,
        image = image,
        weight = def.weight or 1,
    }
end
 
-- Random fish, respecting weights
function pickFishType()
    local total = 0
    for _, fishType in ipairs(FISH_TYPES) do total += fishType.weight end
 
    local roll = math.random() * total
    for _, fishType in ipairs(FISH_TYPES) do
        roll -= fishType.weight
        if roll <= 0 then return fishType end
    end
    return FISH_TYPES[#FISH_TYPES]
end
 
-- Total number of fish caught today
function getCatchTotal()
    local total = 0
    for _, count in pairs(GAME_DATA.catches) do total += count end
    return total
end