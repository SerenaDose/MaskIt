-----------------------------------------------------------------------------------------
--
-- MaskIt -- scores scene
--
-----------------------------------------------------------------------------------------

-- Load libraries
local composer = require("composer")
local widget = require("widget")
local utils = require("utils")

local scene = composer.newScene()

local background
local title
local text01
local text02
local text03
local buttonClose

local fontSize = 100
local HighScores = {}
local textScores = {}
local startvalueY = 500

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
local function onPressButtonClose(event)
    composer.hideOverlay("fade", 400)
end

function scene:create(event)
    local sceneGroup = self.view

    local bg = display.newGroup() 
    local fg = display.newGroup()

    local closeButtonSheet = graphics.newImageSheet("img/ui/button-close.png", utils.optionsRoundedButtons())

    background = display.newImageRect(bg, "bg-dark.png", 1180, 2020)

    title = display.newText({parent = fg, text = "High Scores", font = utils.garamond, fontSize = 150})
    text01 = display.newText({parent = fg, text = "-", font = utils.rubik(), fontSize = fontSize})
    table.insert(textScores, text01)
    text02 = display.newText({parent = fg, text = "-", font = utils.rubik(), fontSize = fontSize})
    table.insert(textScores, text02)
    text03 = display.newText({parent = fg, text = "-", font = utils.rubik(), fontSize = fontSize})
    table.insert(textScores, text03)

    buttonClose =
        widget.newButton(
        {
            sheet = closeButtonSheet,
            defaultFrame = 1,
            overFrame = 2,
            onPress = onPressButtonClose
        }
    )

    -- Recupero i punteggi dal file scores.txt
    HighScores = utils.getScores()

    sceneGroup:insert(bg)
    sceneGroup:insert(fg)
    sceneGroup:insert(buttonClose)
end

-- show()
function scene:show(event)
    local phase = event.phase

    if (phase == "will") then
        background.x = display.contentCenterX
        background.y = display.contentCenterY
        buttonClose.x = display.contentCenterX
        buttonClose.y = display.contentHeight - 200
        -- Testi
        title.x = display.contentCenterX
        title.y = 400

        -- Aggiorno i testi con i punti corretti e li posiziono
        for i = 1, 3 do
            local t = textScores[i]
            t.text = HighScores[4 - i]
            t.x = display.contentCenterX
            t.y = startvalueY + i * 200
        end
    end
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)

return scene
