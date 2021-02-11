-----------------------------------------------------------------------------------------
--
-- MaskIt -- game scene
--
-----------------------------------------------------------------------------------------

local composer = require("composer")
local widget = require("widget")
local utils = require("utils")

local scene = composer.newScene()

local physics = require("physics")
--physics.setDrawMode("hybrid")
physics.start()
physics.pause()

-- * dislay groups
local bg = display.newGroup() -- group of foreground elements
local fg = display.newGroup() -- group of background elements
local touch = display.newGroup()

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
local textScore

-- * variabili di gioco
local gameStarted = false
local timeLeft = 10
local canUpdateTime = false
local totalInfected = 0
local currentInfected = 0
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
local time = 0
local startX = 0
local maskXStart = 0
local isMusicOn
local gameMode
local highScores = {}
local maskAlreadyEnlarged = false
local score = 0
local isMenuOpen = false
local timerTimeLeft = nil
local timerHospital = nil

local polygonShape = {-60, 30, -40, -20, 40, -20, 60, 30}
local rectangleShape = {-80, 30, 80, 30, 80, 20, -80, 20}
local smallRectangleShape = {-50, 20, 50, 20, 50, -15, -50, -15}

-- * touchButtons
local touchRight
local touchLeft
local isPressingRightTouch = false
local isPressingLeftTouch = false

-- * ui
local buttonMenu

-- * music
local bgMusic

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

local function handleButtonMenu(event)
    physics.pause()
    isMenuOpen = true
    if timerTimeLeft ~= nil then
        timer.pause(timerTimeLeft)
    end
    if timerHospital ~= nil then
        timer.pause(timerHospital)
    end
    composer.showOverlay(
        "GameMenu",
        {
            isModal = true,
            effect = "fromTop",
            time = 500
        }
    )
    print("Button was pressed and released")
end

local function formatTime()
    local minutes = math.floor(timeLeft / 60)
    local seconds = timeLeft % 60
    -- Make it a formatted string
    return string.format("%01d:%02d", minutes, seconds)
end

function scene:create(event)
    local sceneGroup = self.view

    local optionsFace = {
        width = 145,
        height = 146,
        numFrames = 2
    }
    local faceSequence = {
        count = 2,
        start = 1,
        loopCount = 1,
        loopDirection = "forward",
        time = 400
    }
    local optionsBM = {
        width = 72,
        height = 72,
        numFrames = 4
    }
    local BMSequence = {
        count = 4,
        start = 1,
        loopCount = 3,
        loopDirection = "forward",
        time = 400
    }

    local menuButtonSheet = graphics.newImageSheet("img/ui/button-menu.png", utils.optionsRoundedButtons())
    local faceSheet = graphics.newImageSheet("img/face.png", optionsFace)
    local heartSheet = graphics.newImageSheet("img/heart.png", optionsBM)
    local hospitalSheet = graphics.newImageSheet("img/hospital.png", optionsBM)

    background = display.newImageRect(bg, "bg.png", 1180, 2020)
    print("game create")
    -- * barriere
    topBarrier = display.newRect(fg, 0, 0, display.contentWidth, 1)
    physics.addBody(
        topBarrier,
        "static",
        {bounce = barrierBounce, friction = barrierFriction, density = barrierDensity, filter = utils.barrierFilter()}
    )

    leftBarrier = display.newRect(fg, 0, 0, 1, display.contentHeight)
    physics.addBody(
        leftBarrier,
        "static",
        {bounce = barrierBounce, friction = barrierFriction, density = barrierDensity, filter = utils.barrierFilter()}
    )

    rightBarrier = display.newRect(fg, 0, 0, 1, display.contentHeight)
    physics.addBody(
        rightBarrier,
        "static",
        {bounce = barrierBounce, friction = barrierFriction, density = barrierDensity, filter = utils.barrierFilter()}
    )

    --maskBottomBarrier = display.newRect(fg,0,0,display.contentWidth,1)
    --physics.addBody(maskBottomBarrier,"static",{ bounce=0, friction=0, density=1, filter=utils.maskBarrierFilter()})

    --maskLeftBarrier = display.newRect(fg,0,0,1,display.contentHeight/2)
    --physics.addBody(maskLeftBarrier,"static",{ bounce=0, friction=0, density=1, filter=utils.maskBarrierFilter()})

    --maskRightBarrier = display.newRect(fg,0,0,1,display.contentHeight/2)
    --physics.addBody(maskRightBarrier,"static",{ bounce=0, friction=0, density=1, filter=utils.maskBarrierFilter()})

    -- * elementi di gioco

    --heart = display.newImageRect(fg, "img/heart.png", 125, 117)
    heart = display.newSprite(fg, heartSheet, BMSequence)
    heart.name = "heart"
    heart.sound = audio.loadSound("sounds/heart.wav")
    physics.addBody(heart, "static", {isSensor = true, filter = utils.bmFilter()})

    --hospital = display.newImageRect(fg, "img/hospital.png", 121, 121)
    hospital = display.newSprite(fg, hospitalSheet, BMSequence)
    hospital.name = "hospital"
    hospital.sound = audio.loadSound("sounds/hospital.wav")
    physics.addBody(hospital, "static", {isSensor = true, filter = utils.bmFilter()})
    --inizializzazione smiles

    local squareShape = {-70, 50, 70, 50, 70, -50, -70, -50}

    for i = 0, 6 do
        local face = display.newSprite(fg, faceSheet, faceSequence)
        face.name = "face" .. i
        face.isAlive = true
        face.isActive = true
        physics.addBody(
            face,
            "static",
            {shape = squareShape, bounce = 1, friction = .8, density = 1.5, filter = utils.faceFilter()}
        )
        table.insert(faces, face)
    end

    local maskOutline = graphics.newOutline(1, "img/mask.png")
    mask = display.newImageRect(fg, "img/mask.png", 161, 53)
    mask.width = mask.width / 100 * 60
    mask.height = mask.height / 100 * 60
    mask.yScaleUp = 1637
    mask.yScaleDown = 1657
    --physics.removeBody(mask)
    physics.addBody(
        mask,
        "static",
        {shape = smallRectangleShape, bounce = 1, friction = .8, density = 1.5, filter = utils.faceFilter()}
    )
    --physics.addBody(mask,"dynamic",{outline=maskOutline, bounce=0,density=1.2,friction=0, filter=utils.maskFilter()})
    --physics.addBody(mask,"static",{ shape = rectangleShape ,density=1.5, friction=0, bounce=1, filter=utils.maskFilter()},{shape=polygonShape, bounce=0,density=1.2,friction=0, filter=utils.barrierFilter()})

    mask.gravityScale = 500
    mask.isFixedRotation = true
    mask.speedX = 1000
    mask.isBullet = true

    --ball = display.newCircle(fg,0,0,50)
    --ball:setFillColor(1,0,0)
    ball = display.newImageRect(fg, "img/virus.png", 100, 100)
    ball.name = "ball"
    physics.addBody(
        ball,
        "dynamic",
        {radius = 50, bounce = ballBounce, density = ballDensity, friction = ballFriction, filter = utils.virusFilter()}
    )
    ball.gravityScale = ballGravity

    textTimeLeft = display.newText({parent = fg, text = formatTime(), font = utils.rubik(), fontSize = 180})
    textScore = display.newText({parent = fg, text = score, font = utils.rubik(), fontSize = 60})
    -- * touch
    touchRight = display.newImageRect(fg, "img/transparent.png", display.contentWidth, display.contentHeight)
    --touchLeft = display.newImageRect(fg, "img/transparent.png", display.contentWidth/2,display.contentHeight)

    touchRight.name = "right"
    --touchLeft.name = "left"

    -- * UI
    buttonMenu =
        widget.newButton(
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
    highScores = utils.getScores()
end

local function moveMaskRight(event)
    print("right")
    if event.phase == "began" then
        --mask:setLinearVelocity(2000,0)
        --isTouchPressed = true
        --isTouchRightPressed = true
        isPressingRightTouch = true
    elseif event.phase == "ended" then
        isPressingRightTouch = false
    --isTouchPressed = false
    end
    return true
end

local function moveMaskLeft(event)
    print("left")
    if event.phase == "began" then
        --mask:setLinearVelocity(-2000,0)
        --mask:applyForce( 500, 0, mask.x-2, mask.y )
        --isTouchPressed = true
        --isTouchRightPressed = false
        isPressingLeftTouch = true
    elseif event.phase == "ended" then
        isPressingLeftTouch = false
    --isTouchPressed = false
    end
    return true
end

local function moveMask2(event)
    local deltaTime = (event.time - time) / 1000
    time = event.time

    if isPressingRightTouch then
        print(isPressingRightTouch)
        if (mask.x + 2000 * deltaTime > display.contentWidth - mask.width / 3 * 2) then
            mask.x = display.contentWidth - mask.width / 3 * 2
        else
            mask.x = mask.x + 2000 * deltaTime
        end
    end

    if isPressingLeftTouch then
        if (mask.x - 2000 * deltaTime < mask.width / 3 * 2) then
            mask.x = mask.width / 3 * 2
        else
            mask.x = mask.x - 2000 * deltaTime
        end
    end

    if (isPressingLeftTouch == false and isPressingRightTouch == false) then
        mask.x = mask.x
    end

    -- move the ball
end

local function updateScore(n)
    score = score + n
    textScore.text = score
end

local function updateTime()
    timeLeft = timeLeft - 1
    textTimeLeft.text = formatTime()
    if currentInfected == 0 then
        updateScore(1)
    end
    --canUpdateTime = true
end

local function updateHospitalIcon()
    print("H")
    if hospital.x < display.contentWidth then
        transition.to(hospital, {time = 1000, alpha = 0, x = display.contentWidth + 500})
    else
        transition.to(hospital, {time = 1000, alpha = 1, x = display.contentWidth - 105})
    end
end

-- local function saveScores(scores)
--     local path = system.pathForFile( "scores.txt", system.DocumentsDirectory )
--     local file, errorString = io.open( path, "w" )

-- for i = 1,3 do
--     local n = " "..scores[i]
--     print(""..scores[i])
--     file:write( n )
-- end
-- io.close( file )
-- end

local function handleGameEnd()
    if (goneToHospital == 7) then
        composer.setVariable("gameMenuMode", "lose")
    else
        composer.setVariable("gameMenuMode", "win")
    end
    if highScores[1] < score then
        highScores[1] = score
    end
    table.sort(highScores)
    utils.saveScores(highScores)

    composer.setVariable("score", score)
    composer.showOverlay(
        "GameMenu",
        {
            isModal = true,
            effect = "fade",
            time = 500
        }
    )
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
    if (vx > 1500 or vy > 1500) then
        print("decrease")
        vx = decreaseVelocity(vx)
        vy = decreaseVelocity(vy)
        self:setLinearVelocity(vx, vy)
        return true
    end
end
local function spawnBall(pos)
    local ball = display.newImageRect(fg, "img/virus.png", 80, 80)
    ball.name = "ball"
    --ball.isActive = false
    physics.addBody(
        ball,
        "dybamic",
        {radius = 40, bounce = ballBounce, density = ballDensity, friction = ballFriction, filter = utils.ballFilter()}
    )
    ball.x = pos
    ball.y = display.contentCenterY - 400
    ball.gravityScale = ballGravity
    --ball.collision = onBallCollision
    --ball:addEventListener( "collision" )
    --ball:applyForce(math.random(-100, 100),math.random(1, 100),ball.x, ball.y)
    if (math.random(0, 1) > 0) then
        ball:applyForce(-8000, 10000, ball.x, ball.y)
    else
        ball:applyForce(8000, 10000, ball.x, ball.y)
    end
end
local function scaleUp()
    mask.width = 161
    mask.height = 53
    mask.y = mask.yScaleUp
    physics.removeBody(mask)
    physics.addBody(
        mask,
        "static",
        {outline = maskOutline, bounce = 0, density = 1.2, friction = 0, filter = utils.maskFilter()}
    )
    --transition.to(textTimeLeft,{time=700,size=500, y = display.contentCenterY})
end

local function scaleDown()
    mask.width = mask.width / 100 * 60
    mask.height = mask.height / 100 * 60
    physics.removeBody(mask)
    mask.y = mask.yScaleDown
    --physics.removeBody(mask)
    physics.addBody(
        mask,
        "static",
        {shape = smallRectangleShape, bounce = 1, friction = .8, density = 1.5, filter = utils.faceFilter()}
    )
end
local function updateEndScore()
    for index, face in ipairs(faces) do
        if (face.isActive and face.isAlive) then
            local textPoints = display.newText({text = "+25", fontSize = "50"})
            textPoints.x = face.x
            textPoints.y = face.y - 150
            transition.to(textPoints, {time = 3000, alpha = 0, y = textPoints.y - 50})
            print("text")
            updateScore(5)
        end
    end
end
local function onUpdate(event)
    if gameStarted then
        if (timeLeft == 0 or goneToHospital == 7) then
            physics.pause()
            gameStarted = false
            if timeLeft == 0 then
                transition.to(textTimeLeft, {time = 700, size = 500, y = display.contentCenterY})
            end
            timer.performWithDelay(1000, updateEndScore)

            audio.fadeOut({channel = 1, time = 5000})
            timer.performWithDelay(3500, handleGameEnd)
        end
    --if canUpdateTime and isMenuOpen==false then
    --timer.performWithDelay(1000, updateTime)
    --canUpdateTime = false
    --end
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
    --if (isPressingLeftTouch==false and isPressingRightTouch==false)then
    --mask:setLinearVelocity(0,0)
    --end
    --moveMask2(event)
    --provare a muovere qui la maschera a dx o sx in base al pulsante premuto
    --if(mask.y>maskY)then
    --mask.y = maskY
    --end
    return true
end

local function startGame()
    physics.start()
    --ball:applyForce(math.random(-100, 100),math.random(1, 100),ball.x, ball.y)
    ball:applyForce(18000, 18000, ball.x, ball.y)
    --mask.width = mask.width/100*50
    --mask.height = mask.height/100*50
    --physics.removeBody(mask)
    --physics.addBody(mask, "static", {shape = squareShape, bounce=1, friction=.8, density=1.5, filter=utils.faceFilter() })
    --transition.to(textTimeLeft,{time=700,size=500, y = display.contentCenterY})
    timerTimeLeft = timer.performWithDelay(1000, updateTime, timeLeft)
    timerHospital = timer.performWithDelay(5000, updateHospitalIcon, timeLeft / 5 - 1)
    gameStarted = true
    canUpdateTime = true
end

local function onTouch(event)
    if (event.phase == "began") then
        print("began")
        maskXStart = mask.x
    end
    if (event.phase == "moved") then
        local offset = (event.xStart - event.x) * 2
        local position = maskXStart - offset
        --print(offset)

        if (position > display.contentWidth - mask.width / 3 * 2) then
            mask.x = display.contentWidth - mask.width / 3 * 2
        elseif (position < mask.width / 3 * 2) then
            mask.x = mask.width / 3 * 2
        else
            mask.x = position
        end
    end
    -- print(event.x)
    -- if(event.x>display.contentWidth/2)then
    --     isPressingRightTouch = true
    --     isPressingLeftTouch = false
    -- else
    --     isPressingRightTouch = false
    --     isPressingLeftTouch = true
    -- end
end

local function onLocalCollisionFace(self, event)
    --print("collision")
    local face = self
    if (event.phase == "began") then
        if (face.isAlive and event.other.name ~= nil and event.other.name == "ball") then
            if face.isActive then
                updateScore(-2)
                face.isActive = false
                totalInfected = totalInfected + 1
                currentInfected = currentInfected + 1
                face:play()
                face.alpha = 0.5
                local spawn = function()
                    return spawnBall(face.x)
                end
                timer.performWithDelay(1, spawn)
            end
        end
    end
    if currentInfected == 1 then
        --local spawn = function() return enlargeBall() end
        timer.performWithDelay(1, scaleUp)
    end
end

local function sensorCollisionHospital(self, event)
    if (event.phase == "began") then
        updateScore(-10)
        local textPoints = display.newText({text = "-5", fontSize = "40"})
        textPoints.x = hospital.x - 100
        textPoints.y = hospital.y
        transition.to(textPoints, {time = 600, alpha = 0})
        self:play()
        audio.play((self).sound, {channel = 3})
        event.other:removeSelf()
        goneToHospital = goneToHospital + 1
        currentInfected = currentInfected - 1
        if currentInfected == 0 then
            timer.performWithDelay(1, scaleDown)
        end
        for index, face in ipairs(faces) do
            if (not (face.isActive) and face.isAlive) then
                face.isAlive = false
                face.alpha = 0
                return true
            end
        end
    end
end

local function sensorCollisionHeart(self, event)
    if (event.phase == "began") then
        updateScore(8)
        local textPoints = display.newText({text = "+5", fontSize = "40"})
        textPoints.x = heart.x + 100
        textPoints.y = heart.y
        transition.to(textPoints, {time = 600, alpha = 0})
        self:play()
        audio.play((self).sound, {channel = 2})
        healed = healed + 1
        currentInfected = currentInfected - 1
        event.other:removeSelf()
        if currentInfected == 0 then
            timer.performWithDelay(1, scaleDown)
        end
        for index, face in ipairs(faces) do
            if (not (face.isActive) and face.isAlive) then
                face.isActive = true
                face.alpha = 1
                face:setFrame(1)
                return true
            end
        end
    end
end

local function onTilt(event)
    function round(num, numDecimalPlaces)
        local mult = 10 ^ (numDecimalPlaces or 0)
        return math.floor(num * mult + 0.5) / mult
    end

    local position = display.contentCenterY / 2 + (event.xGravity * 3 * display.contentCenterY)
    --mappare il valore del giroscopio sull'effettiva lunghezza

    if (position > display.contentWidth - mask.width / 3 * 2) then
        mask.x = display.contentWidth - mask.width / 3 * 2
    elseif (position < mask.width / 3 * 2) then
        mask.x = mask.width / 3 * 2
    else
        mask.x = position
    end --mask:setLinearVelocity(event.xInstant*10000,0)
    --textGravity.text = round(event.xGravity,1)
    --textInstant.text = position
    return true
end

-- show()
function scene:show(event)
    local sceneGroup = self.view
    local phase = event.phase

    if (phase == "will") then
        -- inizializzazione Variabili
        print("game show")

        topBarrier.x = display.contentCenterX
        topBarrier.y = 0
        topBarrier.alpha = 0

        leftBarrier.x = 0
        leftBarrier.y = display.contentCenterY
        leftBarrier.alpha = 0

        rightBarrier.x = display.contentWidth
        rightBarrier.y = display.contentCenterY
        rightBarrier.alpha = 0

        --maskBottomBarrier.x = display.contentCenterX
        --maskBottomBarrier.y = display.contentHeight - 48 - faces[1].height/2 - mask.height/2
        --maskBottomBarrier.alpha = 0

        --maskLeftBarrier.x=5
        --maskLeftBarrier.y=display.contentHeight/4 * 3
        --maskLeftBarrier.alpha=0

        --maskRightBarrier.x=display.contentWidth-5
        --maskRightBarrier.y=display.contentHeight/4 * 3
        --maskRightBarrier.alpha=0

        background.x = display.contentCenterX
        background.y = display.contentCenterY

        for index, face in ipairs(faces) do
            face.x = (index - 1) * 150 + 90
            face.y = display.contentHeight - 175
        end

        ball.x = display.contentCenterX
        ball.y = display.contentCenterY - 400

        mask.x = display.contentCenterX
        local maskY = display.contentHeight - 148 - faces[1].height / 2 - mask.height - 10
        mask.y = maskY
        maskY = nil

        heart.x = 105
        heart.y = 125
        hospital.x = display.contentWidth - 105
        hospital.y = 125

        textTimeLeft.x = display.contentCenterX
        textTimeLeft.y = 400
        textTimeLeft.alpha = 0.5

        textScore.x = display.contentCenterX
        textScore.y = textTimeLeft.y + 130
        textScore.alpha = 0.5
        --textInstant = display.newText(fg, "-", display.contentCenterX, 600, "font/Rubik-Light.ttf", 100 )
        --textGravity = display.newText(fg, "-", display.contentCenterX, 700, "font/Rubik-Light.ttf", 100 )

        touchRight.x = display.contentCenterX
        touchRight.y = display.contentCenterY + 200
        --touchLeft.x = display.contentCenterX/2 -2
        --touchLeft.y = display.contentCenterY+200

        buttonMenu.x = display.contentCenterX
        buttonMenu.y = 100
        audio.setVolume(0.1, {channel = 1})
        audio.setVolume(0.1, {channel = 2})
        audio.setVolume(0.1, {channel = 3})
    elseif (phase == "did") then
        -- Start the physics engine
        --non funziona

        --face:play()
        gameMode = composer.getVariable("gameMode")
        isMusicOn = composer.getVariable("soundOn")
        print(gameMode)
        if (gameMode == "touch") then
            print("touch mode")
            --touchRight:addEventListener("touch",moveMaskRight)
            --touchLeft:addEventListener("touch",moveMaskLeft)
            --touchRight:addEventListener( "touch", onTouch )
            Runtime:addEventListener("touch", onTouch)
        elseif (gameMode == "tilt") then
            print("tilt mode")
            Runtime:addEventListener("accelerometer", onTilt)
        end

        heart.collision = sensorCollisionHeart
        heart:addEventListener("collision")

        hospital.collision = sensorCollisionHospital
        hospital:addEventListener("collision")

        for index, face in ipairs(faces) do
            face.t = test
            face.collision = onLocalCollisionFace
            face:addEventListener("collision")
        end

        if (isMusicOn) then
            audio.play(bgMusic, {loops = -1, fadeIn = 2000, channel = 1})
        end
        Runtime:addEventListener("enterFrame", onUpdate)
        --ball.collision = onBallCollision
        --ball:addEventListener( "collision" )
        startGame()
    end
end
function scene:resumeGame()
    physics.start()
    timer.resume(timerTimeLeft)
    timer.resume(timerHospital)
end

-- hide()
function scene:hide(event)
    local sceneGroup = self.view
    local phase = event.phase

    if (phase == "will") then
        physics.pause()
        Runtime:removeEventListener("enterFrame", update)
        heart:removeEventListener("collision")
        hospital:removeEventListener("collision")
        print("remove")
        timerTimeLeft = nil
        timerHospital = nil
        if (gameMode == "touch") then
            --touchRight:removeEventListener("touch",moveMaskRight)
            --touchLeft:removeEventListener("touch",moveMaskLeft)
            print("remove")
            Runtime:removeEventListener("touch", onTouch)
        elseif (gameMode == "tilt") then
            Runtime:removeEventListener("accelerometer", onTilt)
        end
    elseif (phase == "did") then
        if (isMusicOn) then
            audio.stop(1)
        end
    end
end

function scene:destroy(event)
    local sceneGroup = self.view
    if (isMusicOn) then
        audio.dispose(1)
        audio.dispose(2)
        audio.dispose(3)
    end
end

---------------------------------------
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene
