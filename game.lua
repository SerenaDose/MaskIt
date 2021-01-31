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
local maskRightBarrier
local maskLeftBarrier
local maskBottomBarrier

-- * elementi di gioco
local faces = {}
local mask
local maskY
local ball
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
local barrierBounce = 1
local barrierDensity = 1.5
local barrierFriction = 0
local ballBounce = 1
local ballDensity = 1
local ballFriction = 0
local ballGravity = 0
local isTouchPressed = false
local isTouchRightPressed = false


-- * touchButtons
local touchRight
local touchLeft
local isPressingRightTouch = false
local isPressingLeftTouch = false

-- * ui
local buttonMenu

-- * music
local bgMusic


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

local function handleButtonMenu( event )
    physics.pause()
    composer.showOverlay("GameMenu", {
        isModal = true,
        effect = "fromTop",
        time = 500
    })
    print( "Button was pressed and released" )
end	


function scene:create( event )
 
    local sceneGroup = self.view
	
    background = display.newImageRect(bg, "bg.png", 1180, 2020)
print("game create")
    -- * barriere
    topBarrier = display.newRect(fg,0,0,display.contentWidth,1)
	physics.addBody(topBarrier,"static",{ bounce=barrierBounce, friction=barrierFriction, density=barrierDensity, filter=utils:barrierFilter()})

	leftBarrier = display.newRect(fg,0,0,1,display.contentHeight)
	physics.addBody(leftBarrier,"static",{ bounce=barrierBounce, friction=barrierFriction, density=barrierDensity, filter=utils:barrierFilter()})

	rightBarrier = display.newRect(fg,0,0,1,display.contentHeight)
    physics.addBody(rightBarrier,"static",{ bounce=barrierBounce, friction=barrierFriction, density=barrierDensity, filter=utils:barrierFilter()})

    maskBottomBarrier = display.newRect(fg,0,0,display.contentWidth,1)
	physics.addBody(maskBottomBarrier,"static",{ bounce=0, friction=0, density=1, filter=utils:maskBarrierFilter()})

	maskLeftBarrier = display.newRect(fg,0,0,1,display.contentHeight/2)
	physics.addBody(maskLeftBarrier,"static",{ bounce=0, friction=0, density=1, filter=utils:maskBarrierFilter()})

	maskRightBarrier = display.newRect(fg,0,0,1,display.contentHeight/2)
    physics.addBody(maskRightBarrier,"static",{ bounce=0, friction=0, density=1, filter=utils:maskBarrierFilter()})

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
        face.name = "face"..i
        face.isAlive = true
        face.isActive = true
        local squareShape = { -70,50, 70,50, 70,-50, -70,-50 }
        physics.addBody(face, "static", {shape = squareShape, bounce=1, friction=.8, density=1.5, filter=utils:faceFilter() })
        table.insert(faces, face)
    end

    local maskOutline = graphics.newOutline(1,"img/mask.png")
    mask = display.newImageRect(fg, "img/mask.png", 161, 53)
    local polygonShape = { -60,30, -40,-20, 40,-20, 60,30 }
    local rectangleShape = { -80,30, 80,30, 80,20, -80,20 }
    --physics.addBody(mask,"dynamic",{ radius=30,density=1.5, friction=0, bounce=1, filter=utils:bmFilter()},{outline=maskOutline, bounce=0,density=1.2,friction=0, filter=utils:maskFilter()})
    physics.addBody(mask,"dynamic",{ shape = rectangleShape ,density=1.5, friction=0, bounce=0, filter=utils:maskFilter()},{shape=polygonShape, bounce=0,density=1.2,friction=0, filter=utils:bmFilter()})

    mask.gravityScale = 5
    mask.isFixedRotation = true
    mask.speedX = 1000
    
    --ball = display.newCircle(fg,0,0,50)  
    --ball:setFillColor(1,0,0)
    ball = display.newImageRect(fg, "img/virus.png", 100, 100)   
    ball.name = "ball"
    physics.addBody(ball,"dynamic", {radius=50, bounce=ballBounce, density=ballDensity, friction=ballFriction, filter=utils:virusFilter()} )
    ball.gravityScale = ballGravity


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
            onPress = handleButtonMenu
        }
    )
    fg:insert(buttonMenu)
    buttonMenu:toFront()
	
    sceneGroup:insert(bg)   
    sceneGroup:insert(fg)
    sceneGroup:insert(buttonMenu)
    sceneGroup:insert(touch)

    --music
    bgMusic = audio.loadStream("sounds/bg-music.wav")

end
 
local function moveMaskRight(event)
    if event.phase=="began" then
        --isTouchPressed = true
        --isTouchRightPressed = true
        isPressingRightTouch = true
        mask:setLinearVelocity(2000,0)
    elseif event.phase=="ended" then
        isPressingRightTouch = false
        --isTouchPressed = false
     end
     return true
end

local function moveMaskLeft(event)
    if event.phase=="began" then
        --isTouchPressed = true
        --isTouchRightPressed = false
        isPressingLeftTouch = true
        mask:setLinearVelocity(-2000,0)
                --mask:applyForce( 500, 0, mask.x-2, mask.y )	 
     elseif event.phase=="ended" then
        isPressingLeftTouch = false
        --isTouchPressed = false
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

--local function onBallCollision(self, event)
    --print(self:getLinearVelocity())
--end

local function decreaseVelocity(linearVelocity)
    return linearVelocity * 0.5
end

local function onBallCollision(self, event)
    local vx, vy = self:getLinearVelocity()
   local decreased = false
    while (vx > 1500 or vy > 1500) do
        print("decrease")
        vx = decreaseVelocity(vx)
        vy = decreaseVelocity(vy)
        decreased = true
    end
end
local function spawnBall()
    local ball = display.newImageRect(fg, "img/virus.png", 80, 80)
        ball.name = "ball"
        --ball.isActive = false
        physics.addBody(ball,"dybamic",{radius=40,bounce=ballBounce, density=ballDensity, friction=ballFriction, filter=utils:ballFilter()})
        ball.x = display.contentCenterX
        ball.y = display.contentCenterY
        ball.gravityScale = ballGravity
        ball.collision = onBallCollision
        ball:addEventListener( "collision" )
        --ball:applyForce(math.random(-100, 100),math.random(1, 100),ball.x, ball.y)
        ball:applyForce(-8000,10000,ball.x, ball.y)
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

    --if isTouchPressed then
        --if isTouchRightPressed then
            --mask:setLinearVelocity(2000,0)
        --else
    --         mask:setLinearVelocity(-2000,0)
    --     end
    -- else
    --     mask:setLinearVelocity(0,0)
    -- end
    if (isPressingLeftTouch==false and isPressingRightTouch==false)then
       mask:setLinearVelocity(0,0)
    end

    --provare a muovere qui la maschera a dx o sx in base al pulsante premuto
    --if(mask.y>maskY)then
        --mask.y = maskY
    --end
    return true
end

local function startGame()
    
    physics.start()
    --ball:applyForce(math.random(-100, 100),math.random(1, 100),ball.x, ball.y)
    ball:applyForce(10000,10000,ball.x, ball.y)
    gameStarted = true
    canUpdateTime = true
end


local function onLocalCollisionFace(self, event )
    --print("collision")
    local face = self
    if ( event.phase == "began" ) then
        if (face.isAlive and event.other.name ~= nil and event.other.name == "ball") then
            if face.isActive then
                face.isActive = false
                totalInfected = totalInfected + 1
                face:play()
                face.alpha = 0.5
                local spawn = function() return spawnBall() end
                timer.performWithDelay(  1, spawn )
            end
        end
    end
end


local function sensorCollisionHospital(self, event )
    if ( event.phase == "began" ) then
        self:play()
        event.other:removeSelf()
        goneToHospital = goneToHospital + 1
        for index,face in ipairs(faces) do
            if (face.isActive == false and face.isAlive) then
                face.isAlive = false
                face.alpha = 0
                return true
            end
        end
    end
end

local function sensorCollisionHeart(self, event )
    if ( event.phase == "began" ) then
        self:play()
        healed = healed + 1
        event.other:removeSelf()
        for index,face in ipairs(faces) do
            if (face.isActive == false and face.isAlive) then
                face.isActive = true
                face.alpha = 1
                face:setFrame(1)
                return true
            end
        end
    end
end

local function onTilt( event )

     mask:setLinearVelocity(event.xInstant*10000,0)
     --textInstant.text = event.xInstant
     --textGravity.text = event.xGravity
     return true
 end
local function test(self)
    print("test"..self.name)
end
-- show()
function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        print("game show")

        topBarrier.x=display.contentCenterX
		topBarrier.y=0
		topBarrier.alpha=0
		
		leftBarrier.x=0
		leftBarrier.y=display.contentCenterY
		leftBarrier.alpha=0
		
		rightBarrier.x=display.contentWidth
		rightBarrier.y=display.contentCenterY
        rightBarrier.alpha=0

        maskBottomBarrier.x = display.contentCenterX
        maskBottomBarrier.y = display.contentHeight - 48 - faces[1].height/2 - mask.height/2
        maskBottomBarrier.alpha = 0

        maskLeftBarrier.x=5
		maskLeftBarrier.y=display.contentHeight/4 * 3
		maskLeftBarrier.alpha=0
		
		maskRightBarrier.x=display.contentWidth-5
		maskRightBarrier.y=display.contentHeight/4 * 3
        maskRightBarrier.alpha=0

        
		background.x = display.contentCenterX
        background.y = display.contentCenterY

        for index,face in ipairs(faces) do
            face.x = (index-1)*150 + 90
            face.y = display.contentHeight - 75
        end

        ball.x = display.contentCenterX 
        ball.y = display.contentCenterY - 400

        mask.x = display.contentCenterX
        maskY = display.contentHeight - 48 - faces[1].height/2 - mask.height
        mask.y = maskY

        heart.x = 105
        heart.y = 125
        hospital.x = display.contentWidth - 105
        hospital.y = 125
        
        textTimeLeft = display.newText(fg, formatTime(), display.contentCenterX, 400, "font/Rubik-Light.ttf", 180 )
        textTimeLeft.alpha = 0.5

        touchRight.x = display.contentCenterX + display.contentCenterX/2 +2
        touchRight.y = display.contentCenterY+200
        touchLeft.x = display.contentCenterX/2 -2
        touchLeft.y = display.contentCenterY+200
        
        buttonMenu.x = display.contentCenterX
        buttonMenu.y = 100
        audio.setVolume( 0.1, { channel=1 } ) 
        -- inizializzazione Variabili
        

    elseif ( phase == "did" ) then
        -- Start the physics engine
        --non funziona
        
        --face:play()
        local gameMode = composer.getVariable( "gameMode" )
        print(gameMode)
        if(gameMode == "touch")then
            print("touch mode")
            touchRight:addEventListener("touch",moveMaskRight)
            touchLeft:addEventListener("touch",moveMaskLeft)
        elseif(gameMode == "tilt")then
            print("tilt mode")
            Runtime:addEventListener( "accelerometer", onTilt )
        end

        heart.collision = sensorCollisionHeart
        heart:addEventListener( "collision" )

        hospital.collision = sensorCollisionHospital
        hospital:addEventListener( "collision" )

        for index,face in ipairs(faces) do
            face.t = test
            face.collision = onLocalCollisionFace
            face:addEventListener( "collision" )
        end

        audio.play(bgMusic, {loops = -1, fadeIn=2000, channel=1})
        
        Runtime:addEventListener("enterFrame", update)
        
        startGame()
 
    end
end

 
-- hide()
function scene:hide( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        physics.pause()
        Runtime:removeEventListener("enterFrame", update)
        heart:removeEventListener( "collision" )
        hospital:removeEventListener( "collision" )
        if(gameMode == "touch")then
            touchRight:removeEventListener("touch",moveMaskRight)
            touchLeft:removeEventListener("touch",moveMaskLeft)
        elseif(gameMode == "tilt")then
            Runtime:removeEventListener( "accelerometer", onTilt )
        end
    elseif ( phase == "did" ) then
        print( "did")
        audio.stop(bgMusic)
    end
end
 
 
-- destroy()
function scene:destroy( event )
 
    local sceneGroup = self.view
    audio.dispose(bgMusic)
    -- Code here runs prior to the removal of scene's view
 
end
 
---------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )


return scene
