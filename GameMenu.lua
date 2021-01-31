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


local background
local buttonRestart
local buttonQuit
local buttonInfo
local font = "font/CormorantGaramond-Regular.ttf"
local fonSize = 40

local restartButtonSheet = graphics.newImageSheet( "img/ui/button-restart.png", utils:optionsRectangularButtons() )
local quitButtonSheet = graphics.newImageSheet( "img/ui/button-quit.png", utils:optionsRectangularButtons() )
 
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

local function handleButtonRestart( event )
	--composer.setVariable( "gameMode", gameMode )
	composer.gotoScene("intro", {
		effect = "fade",
		time = 400
	})
    print( "Button Play was pressed and released" )
end	

local function handleButtonQuit( event )
	--composer.setVariable( "gameMode", gameMode )
	composer.gotoScene("menu", {
		effect = "fade",
		time = 400
	})
    print( "Button Play was pressed and released" )
end	

-- create()
function scene:create( event )
 
    local sceneGroup = self.view
    -- Here we create the graphics element of the game
	
	-- Load the background image
    background = display.newImageRect(bg,"img/bg-black-transparent.png",1180,2020)
    
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
	
	sceneGroup:insert(bg)
	sceneGroup:insert(buttonRestart)
	sceneGroup:insert(buttonQuit)
 
end



-- show()
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase

	if ( phase == "will" ) then


		background.x = display.contentCenterX
		background.y = display.contentCenterY

        buttonRestart.x = display.contentCenterX
        buttonRestart.y = display.contentHeight-200

        buttonQuit.x = display.contentCenterX
        buttonQuit.y = display.contentHeight-500

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