-----------------------------------------------------------------------------------------
--
-- instructions view
--
-----------------------------------------------------------------------------------------

-- load the composer library
local composer = require("composer")
local widget = require( "widget" )
local utils = require("utils")
local scene = composer.newScene()
local background
local bg = display.newGroup()
local infoText

local buttonClose
local closeButtonSheet = graphics.newImageSheet( "img/ui/button-close.png", utils.optionsRoundedButtons() )

local function handleButtonEvent( event )
    composer.hideOverlay( "fade", 400 )
    print( "Button was pressed and released" )
end	

function scene:create( event )
 
    local sceneGroup = self.view
    -- Here we create the graphics element of the game
	
	-- Load the background image
    background = display.newImageRect(bg,"img/info.png",1180,2020)
    
    buttonClose = widget.newButton(
	{
		sheet = closeButtonSheet,
		defaultFrame = 1,
		overFrame = 2,
		onPress = handleButtonEvent
	}
	)
	
    sceneGroup:insert(bg)
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

    elseif ( phase == "did" ) then
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
        --local parent = event.parent
        --parent:startGame()
    elseif ( phase == "did" ) then
		--print( "did")
 
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
