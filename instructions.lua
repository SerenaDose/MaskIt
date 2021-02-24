-----------------------------------------------------------------------------------------
--
-- MaskIt - instructions scene
--
-----------------------------------------------------------------------------------------

-- Load libraries
local composer = require("composer")
local widget = require("widget")
local utils = require("utils")
local scene = composer.newScene()

local background
local bg = display.newGroup()

local buttonClose

local function onPressButtonClose(event)
    composer.hideOverlay("fade", 400)
end

function scene:create(event)
    local sceneGroup = self.view
    local closeButtonSheet = graphics.newImageSheet("img/ui/button-close.png", utils.optionsRoundedButtons())

    background = display.newImageRect(bg, "img/instructions.png", 1180, 2020)

    buttonClose =
        widget.newButton(
        {
            sheet = closeButtonSheet,
            defaultFrame = 1,
            overFrame = 2,
            onPress = onPressButtonClose
        }
    )

    sceneGroup:insert(bg)
    sceneGroup:insert(buttonClose)
end

function scene:show(event)
    local phase = event.phase

    if (phase == "will") then
        background.x = display.contentCenterX
        background.y = display.contentCenterY
        buttonClose.x = display.contentCenterX
        buttonClose.y = display.contentHeight - 200
    end
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)

return scene
