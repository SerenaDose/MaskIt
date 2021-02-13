-----------------------------------------------------------------------------------------
--
-- MaskIt -- info scene
--
-----------------------------------------------------------------------------------------

-- Load libraries
local composer = require("composer")
local widget = require("widget")
local utils = require("utils")

local scene = composer.newScene()

local background
local buttonClose

local closeButtonSheet = graphics.newImageSheet("img/ui/button-close.png", utils.optionsRoundedButtons())

local function onPressButtonClose(event)
    composer.hideOverlay("fade", 400)
    print("Button was pressed and released")
end

function scene:create(event)
    local sceneGroup = self.view

    background = display.newImageRect( "img/info.png", 1180, 2020)

    buttonClose =
        widget.newButton(
        {
            sheet = closeButtonSheet,
            defaultFrame = 1,
            overFrame = 2,
            onPress = onPressButtonClose
        }
    )

    sceneGroup:insert(background)
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
