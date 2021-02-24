-----------------------------------------------------------------------------------------
--
-- MaskIt -- game menu scene
--
-----------------------------------------------------------------------------------------

-- Load libraries
local composer = require("composer")
local widget = require("widget")
local utils = require("utils")

local scene = composer.newScene()

local bg = display.newGroup() -- group of foreground elements
-- Tre gruppi che gestistcono cosa mostrare nel menu di gioca a seconda del caso vittoria, sconfitta, pausa
local loseGroup = display.newGroup()
local winGroup = display.newGroup()
local resumeGroup = display.newGroup()

local background
local buttonRestart
local buttonQuit
local buttonResume

local faceHappy
local faceSad

local fontSize = 50
local textWin
local textLose
local textScore

local gameHasToBeResumed = false

local function onPressButtonRestart(event)
    composer.gotoScene(
        "intro",
        {
            effect = "fade",
            time = 400
        }
    )
end

local function onPressButtonQuit(event)
    composer.gotoScene(
        "menu",
        {
            effect = "fade",
            time = 400
        }
    )
end

local function onPressButtonResume(event)
    -- Setto la variabile che controllerò all'hide della scena per sapere se il gioco deve essere ripreso
    gameHasToBeResumed = true
    composer.hideOverlay("fade", 400)
end

function scene:create(event)
    local sceneGroup = self.view
    local restartButtonSheet = graphics.newImageSheet("img/ui/button-restart.png", utils.optionsRectangularButtons())
    local quitButtonSheet = graphics.newImageSheet("img/ui/button-quit.png", utils.optionsRectangularButtons())
    local resumeButtonSheet = graphics.newImageSheet("img/ui/button-resume.png", utils.optionsRectangularButtons())
    
    background = display.newImageRect(bg, "img/bg-black-transparent.png", 1180, 2020)
    faceHappy = display.newImageRect(winGroup, "img/happyFace.png", 300, 300)
    textWin = display.newText({
        parent = winGroup,
        text = "Congrats, you’re a hero! \nYou managed to keep the city safe, now that the vaccine is ready you can rest",   
        width = 650,
        font = utils.garamond,
        fontSize = fontSize,
        align = "center"  
    })
    textScore = display.newText({parent = winGroup, text = "-", font = utils.rubik, fontSize = 200})

    faceSad = display.newImageRect(loseGroup, "img/sadFace.png", 300, 300)
    textLose = display.newText({parent = loseGroup, text = "You failed to prevent the inevitable, all the citizens have been taken in charge by the hospital", width = 750, font = utils.garamond, fontSize = fontSize, align = "center"})
   
    buttonRestart = widget.newButton(
        {
            sheet = restartButtonSheet,
            defaultFrame = 1,
            overFrame = 2,
            onPress = onPressButtonRestart
        }
    )

    buttonQuit = widget.newButton(
        {
            sheet = quitButtonSheet,
            defaultFrame = 1,
            overFrame = 2,
            onPress = onPressButtonQuit
        }
    )

    buttonResume = widget.newButton(
        {
            sheet = resumeButtonSheet,
            defaultFrame = 1,
            overFrame = 2,
            onPress = onPressButtonResume
        }
    )

    sceneGroup:insert(bg)
    sceneGroup:insert(loseGroup)
    sceneGroup:insert(winGroup)
    sceneGroup:insert(buttonRestart)
    sceneGroup:insert(buttonQuit)
    resumeGroup:insert(buttonResume)
    sceneGroup:insert(resumeGroup)
end

function scene:show(event)
    local phase = event.phase

    if (phase == "will") then

        background.x = display.contentCenterX
        background.y = display.contentCenterY

        buttonRestart.x = display.contentCenterX
        buttonRestart.y = display.contentHeight - 500

        buttonQuit.x = display.contentCenterX
        buttonQuit.y = display.contentHeight - 200

        buttonResume.x = display.contentCenterX
        buttonResume.y = display.contentHeight - 800

        textWin.x = display.contentCenterX
        textWin.y = display.contentCenterY 
        faceHappy.x = display.contentCenterX
        faceHappy.y = textWin.y - 350
        textScore.x = display.contentCenterX
        textScore.y = faceHappy.y - 400

        textLose.x = display.contentCenterX
        textLose.y = display.contentCenterY
        faceSad.x = display.contentCenterX
        faceSad.y = textLose.y - 350

        -- In base a quando viene richiamato il menu scelgo cosa mostrare
        if (composer.getVariable("gameMenuMode") == "menu") then
            resumeGroup.alpha = 1
            loseGroup.alpha = 0
            winGroup.alpha = 0
        elseif (composer.getVariable("gameMenuMode") == "win") then
            local score = composer.getVariable("score")
            textScore.text = score
            resumeGroup.alpha = 0
            loseGroup.alpha = 0
            winGroup.alpha = 1
        elseif (composer.getVariable("gameMenuMode") == "lose") then
            resumeGroup.alpha = 0
            loseGroup.alpha = 1
            winGroup.alpha = 0
        end
    end
end

function scene:hide(event)
    local phase = event.phase

    if (phase == "did") then
        if gameHasToBeResumed then
            -- Chiamo la fuzione che fa ripartire il gioco nella scena di gioco
            local parent = event.parent
            parent:resumeGame()
        end
    end
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)

return scene
