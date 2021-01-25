-----------------------------------------------------------------------------------------
--
-- MaskIt -- game scene
--
-----------------------------------------------------------------------------------------


local composer = require( "composer" )
local widget = require( "widget" )
local utils = require("utils")
 
local scene = composer.newScene()
 
physics = require("physics")
--physics.setDrawMode("hybrid")
physics.start()
physics.pause()

-- * dislay groups
bg = display.newGroup()  -- group of foreground elements
fg = display.newGroup()  -- group of background elements
touch = display.newGroup()

local background
-- * barriere
local topBarrier
local leftBarrier
local rightBarrier

-- * elementi di gioco
local faces = {}
local mask
local maskY
local ball
local balls = {}
local heart
local hospital
local textTimeLeft

-- * variabili di gioco
local gameStarted = false
local timeLeft = 120
local canUpdateTime = false
local totalInfected = 0
local healed = 0
local goneToHospital = 0

local textGravity
local textInstant
local prevTilt = 0
-- * touchButtons
local touchRight
local touchLeft
local isPressingRightTouch = false
local isPressingLeftTouch = false

-- * ui
local buttonMenu


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
local optionsBM = {
	width = 125,
    height = 125,
    numFrames = 4,
}
local BMSequence = {
    count = 4, 
    start = 1,
    --name = "infected",
    loopCount = 3,
    loopDirection = "forward",
    time = 400
}

local menuButtonSheet = graphics.newImageSheet( "img/ui/button-menu.png", utils:optionsRoundedButtons() )
local faceSheet = graphics.newImageSheet( "img/face.png", optionsFace )
local heartSheet = graphics.newImageSheet( "img/heart.png", optionsBM )
local hospitalSheet = graphics.newImageSheet( "img/hospital.png", optionsBM )

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

local function handleButtonEvent( event )
 
    print( "Button was pressed and released" )
end	


function scene:create( event )
 
    local sceneGroup = self.view
	
    background = display.newImageRect(bg, "bg.png", 1180, 2020)

    -- * barriere
    topBarrier = display.newRect(fg,0,0,display.contentWidth,1)
	physics.addBody(topBarrier,"static",{ bounce=1, friction=0, density=1.5, filter=utils:barrierFilter()})

	leftBarrier = display.newRect(fg,0,0,1,display.contentHeight)
	physics.addBody(leftBarrier,"static",{ bounce=1, friction=0, density=1.5, filter=utils:barrierFilter()})

	rightBarrier = display.newRect(fg,0,0,1,display.contentHeight)
    physics.addBody(rightBarrier,"static",{ friction=1, density=1.5, filter=utils:barrierFilter()})

    -- * elementi di gioco

    --heart = display.newImageRect(fg, "img/heart.png", 125, 117)
    heart = display.newSprite(fg, heartSheet, BMSequence)
    heart.name = "heart"
    physics.addBody( heart, "static", { isSensor=true, filter=utils:bmFilter() })

    --hospital = display.newImageRect(fg, "img/hospital.png", 121, 121)
    hospital = display.newSprite(fg, hospitalSheet, BMSequence)
    hospital.name = "hospital"
    physics.addBody( hospital, "static", { isSensor=true, filter=utils:bmFilter() })
    --inizializzazione smiles
    for i = 0,6 do 
        local face = display.newSprite(fg, faceSheet, faceSequence)
        face.name = "face"
        face.isActive = true
        physics.addBody(face, "static", {bounce=1, friction=.8, density=1.5, filter=utils:faceFilter() })
        table.insert(faces, face)
    end

    for i = 0,6 do 
        local ball = display.newImageRect(fg, "img/virus.png", 80, 80)
        ball.name = "ball"
        --ball.isActive = false
        physics.addBody(ball,"static",{radius=50,bounce=0.5, filter=utils:ballFilter()})
        ball.isVisible = false
        table.insert(balls, ball)
    end

    local maskOutline = graphics.newOutline(1,"img/mask.png")
    mask = display.newImageRect(fg, "img/mask.png", 161, 53)
    physics.addBody(mask,"dynamic",{outline=maskOutline, bounce=0,density=1.2, filter=utils:maskFilter()})
    mask.gravityScale = 5
    mask.isFixedRotation = true
    mask.speedX = 1000
    
    --ball = display.newCircle(fg,0,0,50)  
    --ball:setFillColor(1,0,0)
    ball = display.newImageRect(fg, "img/virus.png", 100, 100)   
    ball.name = "ball"
    physics.addBody(ball,"dynamic", {radius=50, bounce = 1, filter=utils:virusFilter()} )



    -- * touch
    touchRight = display.newImageRect(fg, "img/transparent.png", display.contentWidth/2,display.contentHeight)
    touchLeft = display.newImageRect(fg, "img/transparent.png", display.contentWidth/2,display.contentHeight)

    touchRight.name = "right"
    touchLeft.name = "left"

    -- * UI
    buttonMenu = widget.newButton(
        {
            sheet = menuButtonSheet,
            defaultFrame = 1,
            overFrame = 2,
            onPress = handleButtonEvent
        }
    )
    fg:insert(buttonMenu)
    buttonMenu:toFront()
	
    sceneGroup:insert(bg)   
    sceneGroup:insert(fg)
    sceneGroup:insert(buttonMenu)
    sceneGroup:insert(touch)

end
 
local function moveMaskRight(event)
    if event.phase=="began" then
        isPressingRightTouch = true
        mask:setLinearVelocity(1000,0)
    elseif event.phase=="ended" then
        isPressingRightTouch = false
     end
     return true
end

local function moveMaskLeft(event)
    if event.phase=="began" then
        isPressingLeftTouch = true
        mask:setLinearVelocity(-1000,0)
                --mask:applyForce( 500, 0, mask.x-2, mask.y )	 
     elseif event.phase=="ended" then
        isPressingLeftTouch = false
     end
     return true
end

local function formatTime()
    local minutes = math.floor( timeLeft / 60 )
    local seconds = timeLeft % 60
    -- Make it a formatted string
    return string.format( "%01d:%02d", minutes, seconds )
end

local function updateTime()
    timeLeft = timeLeft-1
    textTimeLeft.text = formatTime()
    canUpdateTime = true
end

local function handleGameEnd()
    print("gioco finito")
end

local function update(event)
    if gameStarted then
        if (timeLeft==0)then
            physics.pause()
            gameStarted = false
            canUpdateTime = false
            handleGameEnd()
        end
        if canUpdateTime then
            timer.performWithDelay(1000, updateTime)
            canUpdateTime = false
        end
    end

    if (isPressingLeftTouch==false and isPressingRightTouch==false)then
        mask:setLinearVelocity(0,0)
    end
    if(mask.y>maskY)then
        mask.y = maskY
    end
    return true
end

local function startGame()
    ball:applyForce(math.random(-100, 100),math.random(1, 100),ball.x, ball.y)
    gameStarted = true
    canUpdateTime = true
end

local function deactivateFace(face)
    face.alpha = 0.5
    for index,ball in ipairs(balls) do
        if (ball.isVisible == false) then
            print("hit")
            ball.isVisible = true
            ball.y = display.contentCenterY-500
            ball.x = face.x
            ball.bodyType= "dynamic"
            ball:applyForce(math.random(-1000, 1000),math.random(1, 1000),ball.x, ball.y)
            return true
        end
    end
end

local function onLocalCollisionFace(self, event )
    --print("collision")
    local face = self
    --print(face.isActive)
    if ( event.phase == "began" ) then
        if (event.other.name ~= nil and event.other.name == "ball") then
            if face.isActive then
                face.isActive = false
                totalInfected = totalInfected + 1
                face:play()
                local deactivate = function() return deactivateFace( face ) end
                timer.performWithDelay( 700, deactivate )
            end
        end
    end
end

local function deactivateBall(ball)
    ball.bodyType = "static"
    ball.isActive = false
    ball.alpha = 0

    for index,face in ipairs(faces) do
        if (face.isActive == false) then
            face.isActive = true
            face.alpha = 1
            face:setFrame(1)
            return true
        end
    end
    --cambiare posizione?
end

local function sensorCollision(self, event )
    if ( event.phase == "began" ) then
        if (self.name == "hospital") then
            self:play()
            event.other:removeSelf()
            goneToHospital = goneToHospital + 1
        elseif (self.name == "heart") then
            self:play()
            print("collision")
            healed = healed + 1
            local deactivate = function() return deactivateBall( event.other ) end
            timer.performWithDelay( 20, deactivate )
        end
        print(event.other.name)
        print(self.name)
    end
end

local function onTilt( event )
   -- xGravityTxt.text = "xGravity: "..event.xGravity
    --yGravityTxt.text = "yGravity: "..event.yGravity
    --zGravityTxt.text = "zGravity: "..event.zGravity
    --xInstantTxt.text = "xInstant: "..event.xInstant
    --yInstantTxt.text = "yInstant: "..event.yInstant
    --zInstantTxt.text = "zInstant: "..event.zInstant
    --local v = prevTilt - xGravity
    --prevTilt = xG
    mask:setLinearVelocity(event.xInstant*10000,0)
    textInstant.text = event.xInstant
    textGravity.text = event.xGravity
    --mask.x = display.contentCenterX+display.contentCenterX*event.xInstant
    --dot.x = display.contentCenterX+display.contentCenterX*event.xGravity
    --dot.y = display.contentCenterY+display.contentCenterY*event.yGravity

    return true
end

-- show()
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then

        topBarrier.x=display.contentCenterX
		topBarrier.y=0
		topBarrier.alpha=0
		
		leftBarrier.x=0
		leftBarrier.y=display.contentCenterY
		leftBarrier.alpha=0
		
		rightBarrier.x=display.contentWidth
		rightBarrier.y=display.contentCenterY
        rightBarrier.alpha=0
        
		background.x = display.contentCenterX
        background.y = display.contentCenterY

        for index,face in ipairs(faces) do
            face.x = (index-1)*150 + 90
            face.y = display.contentHeight - 75
        end
        --for index,ball in ipairs(balls) do
            --ball.x = display.contentCenterX
            --ball.y = display.contentCenterY-500
            --ball:applyForce(math.random(-100, 100),math.random(1, 100),ball.x, ball.y)
        --end

        ball.x = display.contentCenterX 
        ball.y = display.contentCenterY - 400

        mask.x = display.contentCenterX
        maskY = display.contentHeight - 75 - faces[1].height/2 - mask.height/2
        mask.y = maskY

        heart.x = 105
        heart.y = 125
        hospital.x = display.contentWidth - 105
        hospital.y = 125
        
        textTimeLeft = display.newText(fg, formatTime(), display.contentCenterX, 400, "font/Rubik-Light.ttf", 180 )
        textTimeLeft.alpha = 0.5

        textGravity = display.newText(fg, "-6t87t", display.contentCenterX, 600, "font/Rubik-Light.ttf", 100 )
        textInstant = display.newText(fg, "-6t87t", display.contentCenterX, 800, "font/Rubik-Light.ttf", 100 )

        touchRight.x = display.contentCenterX + display.contentCenterX/2
        touchRight.y = display.contentCenterY+200
        touchLeft.x = display.contentCenterX - display.contentCenterX/2
        touchLeft.y = display.contentCenterY+200
        
        buttonMenu.x = display.contentCenterX
        buttonMenu.y = 100

        -- inizializzazione Variabili
        

    elseif ( phase == "did" ) then
        -- Start the physics engine
        --non funziona
        physics.start()
        --face:play()
        print( "did")	
        --touchRight:addEventListener("touch",moveMaskRight)
        --touchLeft:addEventListener("touch",moveMaskLeft)

        heart.collision = sensorCollision
        heart:addEventListener( "collision" )

        hospital.collision = sensorCollision
        hospital:addEventListener( "collision" )

        for index,face in ipairs(faces) do
            face.collision = onLocalCollisionFace
            face:addEventListener( "collision" )
        end

        Runtime:addEventListener("enterFrame", update)
         
        Runtime:addEventListener( "accelerometer", onTilt )
        startGame()
 
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
