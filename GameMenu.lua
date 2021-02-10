-----------------------------------------------------------------------------------------
--
-- angry smyleys -- game scene
--
-----------------------------------------------------------------------------------------


-- Load the composer library 
local composer = require( "composer" )
local widget = require( "widget" )
local utils = require("utils")
 
-- define a new Scene 
local scene = composer.newScene()
 
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------


bg = display.newGroup()  -- group of foreground elements
fg = display.newGroup()  -- group of background elements
loseGroup = display.newGroup()
winGroup = display.newGroup()
resumeGroup = display.newGroup()

local background
local buttonRestart
local buttonQuit
local buttonInfo
local faceHappy
local faceSad

local font = "font/CormorantGaramond-Regular.ttf"
local fonSize = 40
local textWon
local textLose
local textScore

local gameMenuMode
local gameHasToBeResumed = false

 
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

local function handleButtonRestart( event )
	composer.gotoScene("intro", {
		effect = "fade",
		time = 400
	})
    print( "Button Play was pressed and released" )
end	

local function handleButtonQuit( event )
	composer.gotoScene("menu", {
		effect = "fade",
		time = 400
	})
    print( "Button Play was pressed and released" )
end	

local function handleButtonResume( event )
    gameHasToBeResumed = true
    composer.hideOverlay( "fade", 400 )
end	

-- create()
function scene:create( event )
 
    local sceneGroup = self.view
    -- Here we create the graphics element of the game
	local restartButtonSheet = graphics.newImageSheet( "img/ui/button-restart.png", utils.optionsRectangularButtons() )
    local quitButtonSheet = graphics.newImageSheet( "img/ui/button-quit.png", utils.optionsRectangularButtons() )   
    local resumeButtonSheet = graphics.newImageSheet( "img/ui/button-resume.png", utils.optionsRectangularButtons() )   

    -- Load the background image
    background = display.newImageRect(bg,"img/bg-black-transparent.png",1180,2020)
    faceHappy = display.newImageRect(winGroup, "img/happyFace.png", 300, 300) 
    textWin = display.newText({parent=winGroup, text="Win", font=font, fontSize=fontSize})
    textScore = display.newText({parent=winGroup, text="-", font="font/Rubik-Light.ttf", fontSize=200})

    faceSad = display.newImageRect(loseGroup, "img/sadFace.png", 300, 300)     
    textLose = display.newText({parent=loseGroup, text="Lose", font=font, fontSize=fontSize})
    buttonRestart = widget.newButton(
    {
        sheet = restartButtonSheet,
        defaultFrame = 1,
        overFrame = 2,
        --label = "button",
        onPress = handleButtonRestart
	}
    )
    
    buttonQuit = widget.newButton(
    {
        sheet = quitButtonSheet,
        defaultFrame = 1,
        overFrame = 2,
        --label = "button",
        onPress = handleButtonQuit
    }
    )

    buttonResume = widget.newButton(
    {
        sheet = resumeButtonSheet,
        defaultFrame = 1,
        overFrame = 2,
        --label = "button",
        onPress = handleButtonResume
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



-- show()
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase

	if ( phase == "will" ) then


		background.x = display.contentCenterX
        background.y = display.contentCenterY

        buttonRestart.x = display.contentCenterX
        buttonRestart.y = display.contentHeight-500

        buttonQuit.x = display.contentCenterX
        buttonQuit.y = display.contentHeight-200

        buttonResume.x = display.contentCenterX
        buttonResume.y = display.contentHeight-800

        textWin.x = display.contentCenterX
        textWin.y = display.contentCenterY
        faceHappy.x = display.contentCenterX
        faceHappy.y = textWin.y - 250
        textScore.x = display.contentCenterX
        textScore.y = faceHappy.y -400
        textLose.x = display.contentCenterX
        textLose.y = display.contentCenterY
        faceSad.x = display.contentCenterX
        faceSad.y = textLose.y - 250
        print(composer.getVariable( "gameMenuMode" ))
        if(composer.getVariable( "gameMenuMode" )=="menu")then
            resumeGroup.alpha = 1
            loseGroup.alpha = 0
            winGroup.alpha = 0
        elseif (composer.getVariable( "gameMenuMode")=="win")then
            local score = composer.getVariable( "score")
            textScore.text = score
            resumeGroup.alpha = 0
            loseGroup.alpha = 0
            winGroup.alpha = 1
        elseif (composer.getVariable( "gameMenuMode")=="lose")then
            resumeGroup.alpha = 0
            loseGroup.alpha = 1
            winGroup.alpha = 0
        end

		-- Testi
		--display.newText(fg, "Info", buttonInfo.x , buttonInfo.y + 100, font, fontSize )
		--display.newText(fg,"Scores", buttonScores.x , buttonScores.y + 100, font, fontSize )
		--textMusicState = display.newText(fg, "Music: on", buttonMusic.x , buttonMusic.y + 100, font, fontSize )
		--textGameModeState = display.newText(fg, "Game mode: touch", buttonisGameModeTouch.x , buttonisGameModeTouch.y + 100, font, fontSize )
    elseif ( phase == "did" ) then
    
        --composer.removeScene("game")
		-- Start the physics engine
		--Non Funziona
		--buttonMusic.onPress = onButtonMusicPress
		--buttonisGameModeTouch.onPress = onSwitchPress
		print( "did")	
 
    end
end

 
-- hide()
function scene:hide( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        print( "Will")
    elseif ( phase == "did" ) then
        print( "did")
        if gameHasToBeResumed then
            local parent = event.parent
            parent:resumeGame()
        end
    end
end
 
 
-- destroy()
function scene:destroy( event )
 
    local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view
	--buttonisGameModeTouch:removeSelf()
end
 
---------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )


return scene
