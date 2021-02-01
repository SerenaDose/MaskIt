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
local logo
local buttonPlay
local buttonInfo
local buttonScores
local buttonMusic
local buttonisGameModeTouch
local font = "font/CormorantGaramond-Regular.ttf"
local fontSize = 45
local textMusicState
local textGameModeState
local textButtonInfo
local textButtonScores


local gameMode = "touch"

local playButtonSheet = graphics.newImageSheet( "img/ui/button-play.png", utils:optionsRectangularButtons() )
local infoButtonSheet = graphics.newImageSheet( "img/ui/button-info.png", utils:optionsRoundedButtons() )
local scoresButtonSheet = graphics.newImageSheet( "img/ui/button-scores.png", utils:optionsRoundedButtons() )
local musicButtonSheet = graphics.newImageSheet( "img/ui/button-sound.png", utils:optionsChecboxButton() )
local gameModeButtonSheet = graphics.newImageSheet( "img/ui/button-gameMode.png", utils:optionsChecboxButton() )
 
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
local function handleButtonEvent( event )
 
    print( "Button was pressed and released" )
end	

local function handleButtonInfo( event )
	composer.showOverlay("info", {
		effect = "fade",
		time = 400
	})
end	

local function handleButtonPlay( event )
	composer.setVariable( "gameMode", gameMode )
	composer.gotoScene("intro", {
		effect = "fade",
		time = 400
	})
    print( "Button Play was pressed and released" )
end	

local function onButtonMusicPress( event )
	local switch = event.target
	if switch.isOn then
		textMusicState.text = "Music: on"
	else
		textMusicState.text = "Music: off"
	end
    --print( "Switch with ID '"..switch.id.."' is on: "..tostring(switch.isOn) )
end

local function onGameModePress( event )
	local switch = event.target
    if switch.isOn then
		textGameModeState.text = "Game mode: touch"
		gameMode = "touch"
	else
		textGameModeState.text = "Game mode: tilt"
		gameMode = "tilt"
	end
    --print( "Switch with ID '"..switch.id.."' is on: "..tostring(switch.isOn) )
end


-- create()
function scene:create( event )
 
    local sceneGroup = self.view
    -- Here we create the graphics element of the game
	
	-- Load the background image
	background = display.newImageRect(bg,"bg-dark.png",1180,2020)
	logo = display.newImageRect(fg,"img/ui/logo.png",699,477)
	buttonPlay = widget.newButton(
    {
        sheet = playButtonSheet,
        defaultFrame = 1,
        overFrame = 2,
        --label = "button",
        onPress = handleButtonPlay
	}
	)
	buttonInfo = widget.newButton(
	{
		sheet = infoButtonSheet,
		defaultFrame = 1,
		overFrame = 2,
		onPress = handleButtonInfo
	}
	)
	buttonScores = widget.newButton(
	{
		sheet = scoresButtonSheet,
		defaultFrame = 1,
		overFrame = 2,
		onPress = handleButtonEvent
	}
	)
	
 	buttonMusic = widget.newSwitch(
    {
        style = "checkbox",
        id =  "buttonMusic",
        width = 119,
		height = 117,
		initialSwitchState = true,
		onPress = onButtonMusicPress,
        sheet = musicButtonSheet,
        frameOff = 2,
        frameOn = 1
	}
	)
	buttonisGameModeTouch = widget.newSwitch(
    {
        style = "checkbox",
        id =  "buttonMusic",
        width = 119,
		height = 117,
		initialSwitchState = true,
		onPress = onGameModePress,
        sheet = gameModeButtonSheet,
        frameOff = 2,
        frameOn = 1
    }
	)
	
	textMusicState = display.newText({parent=fg, text="Music: on", font=font, fontSize=fontSize})
	textGameModeState = display.newText({parent=fg, text="Game mode: touch",font=font, fontSize=fontSize})
	textButtonInfo = display.newText({parent=fg, text="Info", font=font, fontSize=fontSize})
	textButtonScores = display.newText({parent=fg, text="Scores", font=font, fontSize=fontSize})

	sceneGroup:insert(bg)
	sceneGroup:insert(fg)
	sceneGroup:insert(buttonisGameModeTouch)
	sceneGroup:insert(buttonInfo)
	sceneGroup:insert(buttonMusic)
	sceneGroup:insert(buttonPlay)
	sceneGroup:insert(buttonScores)
 
end



-- show()
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase

	if ( phase == "will" ) then

		background.x = display.contentCenterX
		background.y = display.contentCenterY

		buttonPlay.x = display.contentCenterX
		buttonPlay.y = display.contentHeight-200

		buttonInfo.x = 118
		buttonInfo.y = 118

		buttonScores.x = display.contentWidth - 118
		buttonScores.y = 118

		logo.x = display.contentCenterX -10
		logo.y = 600

	 	buttonMusic.x = display.contentCenterX
		buttonMusic.y = display.contentCenterY+100
		 
		buttonisGameModeTouch.x = display.contentCenterX
		buttonisGameModeTouch.y = buttonMusic.y + 250
		
		-- Testi
		textButtonInfo.x = buttonInfo.x
		textButtonInfo.y = buttonInfo.y + 100
		textButtonScores.x = buttonScores.x
		textButtonScores.y = buttonScores.y + 100
		textMusicState.x = buttonMusic.x
		textMusicState.y = buttonMusic.y + 100
		textGameModeState.x = buttonisGameModeTouch.x
		textGameModeState.y = buttonisGameModeTouch.y + 100

	elseif ( phase == "did" ) then
		
	elseif ( phase == "did" ) then
		composer.removeScene("game")
		--composer.removeHidden()

		--Non Funziona
		--buttonInfo.onPress = handleButtonInfo
		--buttonInfo:addEventListener("onPress")
		print( "did")	
 
    end
end

 
-- hide()
function scene:hide( event )
 
	local sceneGroup = self.view
	sceneGroup.alpha = 0
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
