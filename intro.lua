-----------------------------------------------------------------------------------------
--
-- MaskIt Intro scene
--
-----------------------------------------------------------------------------------------

-- Load libraries
local composer = require("composer")

local scene = composer.newScene()

local background
local bg = display.newGroup()

-- Al tap carico la scena di gioco
local function startGame(event)
    -- Setto la variabile che mi permetterà di capire se nel menu di gioco devo mostrare solo i pulsanti o una
    composer.setVariable("gameMenuMode", "menu")
    composer.gotoScene(
        "game",
        {
            effect = "fade",
            time = 400
        }
    )
end

function scene:create(event)
    local sceneGroup = self.view

    background = display.newImageRect(bg, "img/intro.png", 1180, 2020)
    sceneGroup:insert(bg)
end

-- show()
function scene:show(event)
    local phase = event.phase

    if (phase == "will") then
        background.x = display.contentCenterX
        background.y = display.contentCenterY
        -- Se il gioco viene giocato per la prima volta mostro la scena delle istruzioni
        if composer.getVariable("showInstructions") == "1" then
            composer.showOverlay(
                "instructions",
                {
                    isModal = true,
                    effect = "fade",
                    time = 1
                }
            )
        end
    elseif (phase == "did") then
        composer.removeScene("game")
        Runtime:addEventListener("tap", startGame)
    end
end

function scene:hide(event)
    local phase = event.phase

    if (phase == "will") then
        Runtime:removeEventListener("tap", startGame)
    elseif (phase == "did") then
        composer.removeScene("info")
    end
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)

return scene
