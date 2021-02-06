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
local musicOn = "true"

 
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

local function handleButtonScores( event )
	composer.showOverlay("scores", {
		effect = "fade",
		time = 400
	})
end	

local function handleButtonPlay( event )
	composer.setVariable( "gameMode", gameMode )
	composer.setVariable( "soundOn", musicOn )
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
		musicOn = true
	else
		textMusicState.text = "Music: off"
		musicOn = false
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

local function readScores()
	local path = system.pathForFile( "scores.txt", system.DocumentsDirectory )
	-- Open the file handle
	local file, errorString = io.open( path, "r" )
	if not file then
	-- Error occurred; output the cause
		print( "File error: " .. errorString )
		local file, errorString = io.open( path, "w" )
		print("create new file")
		file:write( "6 9 2" )
		io.close( file )
	end
	file = nil
	local file, errorString = io.open( path, "r" )
	local scores={}
	for i = 1,3 do 			
		local n = file:read("*n")
		print("Numero trovato"..n)
		table.insert(scores, n)
		print(scores)
	end

	local sortedScores = {}
	for k, v in pairs(scores) do
    	table.insert(sortedScores,{k,v})
	end

	table.sort(sortedScores, function(a,b) return a[2] < b[2] end)

for _, v in ipairs(sortedScores) do
    print(v[1],v[2])
end
	composer.setVariable( "scores", scores )
	scores = nil
	io.close( file )
	file = nil
end
-- create()
function scene:create( event )
 
    local sceneGroup = self.view
    -- Here we create the graphics element of the game
	
local playButtonSheet = graphics.newImageSheet( "img/ui/button-play.png", utils:optionsRectangularButtons() )
local infoButtonSheet = graphics.newImageSheet( "img/ui/button-info.png", utils:optionsRoundedButtons() )
local scoresButtonSheet = graphics.newImageSheet( "img/ui/button-scores.png", utils:optionsRoundedButtons() )
local musicButtonSheet = graphics.newImageSheet( "img/ui/button-sound.png", utils:optionsChecboxButton() )
local gameModeButtonSheet = graphics.newImageSheet( "img/ui/button-gameMode.png", utils:optionsChecboxButton() )
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
		onPress = handleButtonScores
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
	local path = system.pathForFile( "scores.txt", system.DocumentsDirectory )

	--readScores()
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
		
		print("sssssssssss")
		composer.removeScene("game")
		--composer.removeHidden()

		--Non Funziona
		buttonInfo.onPress = handleButtonInfo
		buttonInfo:addEventListener("onPress")
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
