-----------------------------------------------------------------------------------------
--
-- angry smyleys -- game scene
--
-----------------------------------------------------------------------------------------


-- Load the composer library 
local composer = require( "composer" )
local widget = require( "widget" )
 
-- define a new Scene 
local scene = composer.newScene()
 


-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
physics = require("physics")
physics.setDrawMode("hybrid")
physics.start()
physics.pause()

bg = display.newGroup()  -- group of foreground elements
fg = display.newGroup()  -- group of background elements
touch = display.newGroup()


local background
local topBarrier
local leftBarrier
local rightBarrier
local faces = {}
local mask
local ball
local time = 0
local isPressingRightTouch = false
local isPressingLeftTouch = false

--touchButtons
local touchRight
local touchLeft

--ui
local buttonMenu


local optionsRoundedButtons = {
	width = 119,
    height = 121,
    numFrames = 2,
}
local optionsFace = {
	width = 145,
    height = 146,
    numFrames = 2,
}
local faceSequence = {
    count = 2, 
    start = 1,
    name = "infected",
    loopCount = 1,
    loopDirection = "forward",
    time = 400
}

local menuButtonSheet = graphics.newImageSheet( "img/ui/button-menu.png", optionsRoundedButtons )
local faceSheet = graphics.newImageSheet( "img/face.png", optionsFace )
 
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

local function handleButtonEvent( event )
 
    print( "Button was pressed and released" )
end	

-- create()
function scene:create( event )
 
    local sceneGroup = self.view
    -- Here we create the graphics element of the game
	
	-- Load the background image
    background = display.newImageRect(bg, "bg.png", 1180, 2020)

    for i = 0,6 do 
        local face = display.newSprite(fg, faceSheet, faceSequence)
        physics.addBody(face,"static",{bounce=0.2,friction=.8,density=1.5})
        table.insert(faces, face)
    end
    local maskOutline = graphics.newOutline(1,"img/mask.png")

    mask = display.newImageRect(bg, "img/mask.png", 161, 53)
    physics.addBody(mask,"dynamic",{outline=maskOutline, bounce=0,density=1.2})
    mask.gravityScale = 5
    mask.isFixedRotation = true
    mask.speedX = 1000

    topBarrier = display.newRect(fg,0,0,display.contentWidth,1)
	physics.addBody(topBarrier,"static",{bounce=0,friction=0,density=1.5})
	
	-- Create a left barrier to prevent the smile from exiting the display
	-- and add a static body to it
	leftBarrier = display.newRect(fg,0,0,1,display.contentHeight)
	physics.addBody(leftBarrier,"static",{bounce=0,friction=0,density=1.5})
	
	-- Create a  right barrier to prevent the smile from exiting the display
	-- and add a static body to it
	rightBarrier = display.newRect(fg,0,0,1,display.contentHeight)
    physics.addBody(rightBarrier,"static",{friction=0,density=1.5})
    ball = display.newCircle(0,0,50)  

    ball:setFillColor(1,0,0)
    
    physics.addBody(ball,"dynamic", {radius=50, bounce = 1} )
    --touchRight = display.newRect(touch, 0, 0, display.contentCenterX, display.contentHeight-200)
    touchRight = display.newImageRect(fg, "img/transparent.png", display.contentWidth/2,display.contentHeight)
    touchLeft = display.newImageRect(fg, "img/transparent.png", display.contentWidth/2,display.contentHeight)

    --touchRight:setFillColor(1,0,0)
    --touchRight.alpha = 0
    touchRight.name = "right"
    touchLeft.name = "left"

    buttonMenu = widget.newButton(
        {
            sheet = menuButtonSheet,
            defaultFrame = 1,
            overFrame = 2,
            onPress = handleButtonEvent
        }
    )
    fg:insert(buttonMenu)
	
    sceneGroup:insert(bg)
    
    sceneGroup:insert(fg)
    sceneGroup:insert(buttonMenu)
    sceneGroup:insert(touch)

 
end

local function moveMaskRight(event)
    -- select the arrow touched	
    local button=event.target
    
    -- if the touch event has just started...
    if event.phase=="began" then
        
        -- ... and arrowUp has been touched
        print("pressed")
        isPressingRightTouch = true
     -- if the touch event ended (i.e. the arrow has been released)...   
     elseif event.phase=="ended" then
              -- ... just set to 0 the ball speed 
        isPressingRightTouch = false
     end
     return true
 end

local function moveMaskLeft(event)
    -- select the arrow touched	
    local button=event.target
    
    -- if the touch event has just started...
    if event.phase=="began" then
        print("pressed")
        isPressingLeftTouch = true
     -- if the touch event ended (i.e. the arrow has been released)...   
     elseif event.phase=="ended" then
              -- ... just set to 0 the ball speed 
        isPressingLeftTouch = false
     end
     return true

 end
 
 local function moveMask(event)
    -- select the arrow touched	
    local button=event.target
    
    -- if the touch event has just started...
    if event.phase=="began" then
        
        -- ... and arrowUp has been touched
        if button.name=="right" then
            isPressingRightTouch = true
            print("pressed")
              -- ... set the ball speed equal to -50 pixels per second 
              -- (the ball direction points upwards)

            mask:setLinearVelocity(1000,0)
                --mask:applyForce( 500, 0, mask.x-2, mask.y )

              
         -- ... and arrowDown has been touched		 
        elseif button.name=="left" then
            isPressingLeftTouch = true
              -- ... set the ball speed equal to 50 pixels per second 
              -- (the ball direction points downwards)
              mask:setLinearVelocity(-1000,0)
        end
     -- if the touch event ended (i.e. the arrow has been released)...   
     elseif event.phase=="ended" then
              -- ... just set to 0 the ball speed 
            if button.name=="right" then
                isPressingRightTouch = false
            else
                isPressingLeftTouch = false
            end
            mask:setLinearVelocity(0,0)
     end
     return true
 end

 local function update(event)
    if (isPressingLeftTouch or isPressingRightTouch)then
        print("si muove")
    else
        mask:setLinearVelocity(0,0)
    end
    return true
end
    

 local function moveMask2(event)

   
    local deltaTime = (event.time-time)/1000
    time = event.time

    if isPressingRightTouch then
        print(isPressingRightTouch)
        if (mask.x > display.contentWidth - mask.width) then
            mask.x = display.contentWidth - mask.width
        else
            mask.x = mask.x + mask.speedX*deltaTime
        end
    end

    if isPressingLeftTouch then
        if (mask.x < mask.width) then
            mask.x = mask.width
        else
            mask.x = mask.x - mask.speedX*deltaTime
        end
        
    end

    -- move the ball  	
 end
  


-- show()
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then

        topBarrier.x=display.contentCenterX
		topBarrier.y=0
		topBarrier.alpha=0
		
		-- place the top barrier at the left border of the display
		-- and make it transparent
		leftBarrier.x=0
		leftBarrier.y=display.contentCenterY
		leftBarrier.alpha=0
		
		-- place the right barrier at the right border of the display
		-- and make it transparent
		rightBarrier.x=display.contentWidth
		rightBarrier.y=display.contentCenterY
        rightBarrier.alpha=0
        
		background.x = display.contentCenterX
        background.y = display.contentCenterY

        --face.x = display.contentCenterX
        --face.y = display.contentCenterY
        for index,face in ipairs(faces) do
            face.x = (index-1)*150 + 90
            face.y = display.contentHeight - 75
        end

        ball.x = display.contentCenterX 
        ball.y = display.contentCenterY

        mask.x = display.contentCenterX
        mask.y = display.contentHeight - 190

        touchRight.x = display.contentCenterX + display.contentCenterX/2
        touchRight.y = display.contentCenterY+200
        touchLeft.x = display.contentCenterX - display.contentCenterX/2
        touchLeft.y = display.contentCenterY+200
        
        buttonMenu.x = display.contentCenterX
        buttonMenu.y = 100
    elseif ( phase == "did" ) then
        -- Start the physics engine
        --non funziona
        physics.start()
        --face:play()
        print( "did")	
        touchRight:addEventListener("touch",moveMask)
        touchLeft:addEventListener("touch",moveMask)
        --touchRight:addEventListener("touch", moveMaskRight)
        --touchLeft:addEventListener("touch", moveMaskLeft)
        Runtime:addEventListener("enterFrame", update)
 
    end
end

 
-- hide()
function scene:hide( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        physics.pause()
    elseif ( phase == "did" ) then
		print( "did")
 
    end
end
 
 
-- destroy()
function scene:destroy( event )
 
    local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view
 
end
 
---------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )


return scene
