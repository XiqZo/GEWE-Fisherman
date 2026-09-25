import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/easing"
import "CoreLibs/ui"

import "SceneManager"

import "FishTypes"
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

GAME_DATA = pd.datastore.read("gameData") or {}
GAME_DATA.catchOfTheDay = GAME_DATA.catchOfTheDay or 0
GAME_DATA.catches = GAME_DATA.catches or {}

SCENE_MANAGER = SceneManager()
SCENE_MANAGER:switchScene(GameStartScene)

function pd.update()
    gfx.sprite.update()
    pd.timer.updateTimers()
end
