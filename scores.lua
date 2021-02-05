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
local HighScores = {}
local garamond = "font/CormorantGaramond-Regular.ttf"
local rubik ="font/Rubik-Light.ttf"
local fontSize = 100
local textScores = {}
local startvalue = 500

local closeButtonSheet = graphics.newImageSheet( "img/ui/button-close.png", utils:optionsRoundedButtons() )

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
local function handleButtonClose( event )
    composer.hideOverlay( "fade", 400 )
end	
-- create()
function scene:create( event )
 
    local sceneGroup = self.view
    -- Here we create the graphics element of the game
	
	-- Load the background image
    background = display.newImageRect(bg,"bg-dark.png",1180,2020)

    title = display.newText({parent=fg, text="High Scores", font=garamond, fontSize=150})
    text01 = display.newText({parent=fg, text="-", font=rubik, fontSize=fontSize})
    table.insert( textScores, text01)
    text02 = display.newText({parent=fg, text="-", font=rubik, fontSize=fontSize})
    table.insert( textScores, text02)
    text03 = display.newText({parent=fg, text="-", font=rubik, fontSize=fontSize})
    table.insert( textScores, text03)

    buttonClose = widget.newButton(
	{
		sheet = closeButtonSheet,
		defaultFrame = 1,
		overFrame = 2,
		onPress = handleButtonClose
	}
	)

    HighScores = utils:getScores()

    sceneGroup:insert(bg)
    sceneGroup:insert(fg)
    sceneGroup:insert(buttonClose)
	
end



-- show()
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase

	if ( phase == "will" ) then
        
        background.x = display.contentCenterX
        background.y = display.contentCenterY
        buttonClose.x = display.contentCenterX
		buttonClose.y = display.contentHeight -200
		-- Testi
		title.x = display.contentCenterX
		title.y = 400

        for i = 1,3 do 	
            local t = textScores[i]
            t.text = HighScores[4-i]
            t.x = display.contentCenterX
            t.y = startvalue + i*200
        end

	elseif ( phase == "did" ) then
		
		--composer.removeHidden()

		--Non Funziona
		--buttonInfo.onPress = handleButtonInfo
		--buttonInfo:addEventListener("onPress")
		print( "did")	
		
    end
end

 
-- hide()
function scene:hide( event )
 
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
