import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/easing"
import "CoreLibs/ui"

import "SceneManager"

import "fishTypes"
import "Player"
import "FishingRod"
import "Fish"
import "Boat"

import "Scenes/GameStartScene"
import "Scenes/FishingScene"
import "Scenes/GameEndScene"
import "Scenes/SailingScene"
 
local pd <const> = playdate
local gfx <const> = pd.graphics
 
pd.display.setRefreshRate(30)
 
-- Data that outlives scenes AND app restarts (loaded from disk if it exists)
GAME_DATA = pd.datastore.read() or {}
GAME_DATA.catches = GAME_DATA.catches or {}  -- fish id -> count, e.g. { fish1 = 2, fish3 = 1 }
GAME_DATA.catchOfTheDay = nil                -- old format, no longer used
 
local function saveGame()
    pd.datastore.write(GAME_DATA)
end
function pd.gameWillTerminate() saveGame() end  -- player exits via the Home menu
function pd.deviceWillSleep() saveGame() end
 
SCENE_MANAGER = SceneManager()
GameStartScene()
 
function pd.update()
    gfx.sprite.update()      -- calls update() on every scene (they're sprites) and draws
    pd.timer.updateTimers()  -- REQUIRED, otherwise the wipe transition never finishes
end