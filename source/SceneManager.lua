local pd <const> = playdate
local gfx <const> = playdate.graphics

SceneManager = {}
class("SceneManager").extends()

function SceneManager:init()
    self.transitionTime = 500
    self.transitioning = false

    self.currentScene = nil
    self.newScene = nil
    self.sceneArgs = nil

    self.transitionSprite = nil
end


function SceneManager:switchScene(scene, ...)
    if self.transitioning then
        return
    end

    self.transitioning = true

    self.newScene = scene
    self.sceneArgs = { ... }

    self:startTransition()
end


function SceneManager:startTransition()

    -- Cover the current scene.
    local transitionTimer =
        self:wipeTransition(0, 400)

    transitionTimer.timerEndedCallback = function()

        -- Now that the screen is completely black,
        -- remove the old scene and create the new one.
        self:loadNewScene()

        -- Reveal the new scene.
        local revealTimer =
            self:wipeTransition(400, 0)

        revealTimer.timerEndedCallback = function()

            self.transitioning = false

            if self.transitionSprite then
                self.transitionSprite:remove()
                self.transitionSprite = nil
            end

            -- Force the final scene to redraw.
            self:markAllSpritesDirty()
        end
    end
end


function SceneManager:loadNewScene()

    -- Remove the old scene.
    self:cleanupScene()

    -- Create the new scene.
    self.currentScene =
        self.newScene(table.unpack(self.sceneArgs))

    self.newScene = nil
    self.sceneArgs = nil

    -- Make sure the new scene gets drawn.
    self:markAllSpritesDirty()
end


function SceneManager:cleanupScene()

    if self.currentScene then
        self.currentScene:cleanup()
        self.currentScene = nil
    end

    gfx.setDrawOffset(0, 0)
end


function SceneManager:markAllSpritesDirty()

    local sprites = gfx.sprite.getAllSprites()

    for i = 1, #sprites do
        sprites[i]:markDirty()
    end
end


function SceneManager:wipeTransition(startValue, endValue)

    local transitionSprite =
        self:createTransitionSprite()

    transitionSprite:setClipRect(
        0,
        0,
        startValue,
        240
    )

    local transitionTimer = pd.timer.new(
        self.transitionTime,
        startValue,
        endValue,
        pd.easingFunctions.inOutCubic
    )

    transitionTimer.updateCallback = function(timer)

        if transitionSprite then
            transitionSprite:setClipRect(
                0,
                0,
                timer.value,
                240
            )
        end
    end

    return transitionTimer
end


function SceneManager:createTransitionSprite()

    if self.transitionSprite then
        self.transitionSprite:remove()
    end

    local image = gfx.image.new(
        400,
        240,
        gfx.kColorBlack
    )

    local sprite = gfx.sprite.new(image)

    sprite:moveTo(200, 120)
    sprite:setZIndex(10000)
    sprite:setIgnoresDrawOffset(true)
    sprite:add()

    self.transitionSprite = sprite

    return sprite
end
