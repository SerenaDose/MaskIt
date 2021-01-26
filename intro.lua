-----------------------------------------------------------------------------------------
--
-- instructions view
--
-----------------------------------------------------------------------------------------

-- load the composer library
local composer = require("composer")
local scene = composer.newScene()
local background
local bg = display.newGroup()


local function startGame( event )
    composer.gotoScene("game", {
		effect = "fade",
		time = 400
	})
end	

function scene:create( event )
 
    local sceneGroup = self.view
    -- Here we create the graphics element of the game
	
	-- Load the background image
    background = display.newImageRect(bg,"img/intro.png",1180,2020)
	
    sceneGroup:insert(bg) 
end



-- show()
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase

	if ( phase == "will" ) then
		background.x = display.contentCenterX
        background.y = display.contentCenterY

        composer.showOverlay("instructions", {
            effect = "fade",
            time = 1
        })
    elseif ( phase == "did" ) then
		-- Start the physics engine

		print( "did")	
        Runtime:addEventListener("touch",startGame)	
        
    end
end

 
-- hide()
function scene:hide( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then

    elseif ( phase == "did" ) then
        print( "did")
        composer.removeScene("info")
 
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