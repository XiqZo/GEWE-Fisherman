local pd <const> = playdate
local gfx <const> = playdate.graphics

class('SceneManager').extends()

function SceneManager:init()
    self.transitionTime = 1000
    self.transitioning = false
end

function SceneManager:switchScene(scene, ...)

    if self.transitioning then
        return
    end

    self.transitioning = true

    self.newScene = scene
    local args = {...}
    self.sceneArgs = args

     self:startTransition()
end


function SceneManager:startTransition()
    local transitionTimer = self:wipeTransition(0, 400)

    transitionTimer.timerEndedCallback = function()
        self:loadNewScene()
        transitionTimer = self:wipeTransition(400, 0)
        transitionTimer.timerEndedCallback = function()
            self.transitioning = false
            self.transitionSprite:remove()
            -- Temp fix to resolve bug with sprite artifacts/smearing after transition
            local allSprites = gfx.sprite.getAllSprites()
            for i=1,#allSprites do
                allSprites[i]:markDirty()
            end
        end
    end
end


function SceneManager:loadNewScene()
    self:cleanupScene()
    -- Keep a reference so the NEXT switch can clean this one up properly (see cleanupScene)
    self.currentScene = self.newScene(table.unpack(self.sceneArgs))
end

function SceneManager:cleanupScene()
    -- Let the outgoing scene clean up anything sprite.removeAll() won't catch,
    -- e.g. FishingScene's "Back to pier" system menu item. Without this, that
    -- entry stays in the menu and gets duplicated next time you go fishing.
    if self.currentScene and self.currentScene.cleanup then
        self.currentScene:cleanup()
    end
    self.currentScene = nil

    gfx.sprite.removeAll()
    self:removeAllTimers()
    gfx.setDrawOffset(0, 0)
end

function SceneManager:wipeTransition(startValue, endValue)
    local transitionSprite = self:createTransitionSprite()
    transitionSprite:setClipRect(0, 0, startValue, 240)

    local transitionTimer = pd.timer.new(self.transitionTime, startValue, endValue, pd.easingFunctions.inOutCubic)
    transitionTimer.updateCallback = function(timer)
        transitionSprite:setClipRect(0, 0, timer.value, 240)
    end
    return transitionTimer
end


function SceneManager:createTransitionSprite()
    local filledRect = gfx.image.new(400, 240, gfx.kColorBlack)
    local transitionSprite = gfx.sprite.new(filledRect)
    transitionSprite:moveTo(200, 120)
    transitionSprite:setZIndex(10000)
    transitionSprite:setIgnoresDrawOffset(true)
    transitionSprite:add()
    self.transitionSprite = transitionSprite
    return transitionSprite
end

function SceneManager:removeAllTimers()
    local allTimers = pd.timer.allTimers()
    for _, timer in ipairs(allTimers) do
        timer:remove()
    end
end