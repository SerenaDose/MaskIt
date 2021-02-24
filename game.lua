-----------------------------------------------------------------------------------------
--
-- MaskIt -- game scene
--
-----------------------------------------------------------------------------------------

-- Load libraries
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

-- * elementi di gioco
local faces = {}
local mask
local ball
local heart
local hospital
local textTimeLeft
local textScore
local maskOutline

-- * variabili di gioco
local timeLeft = 120
local totalInfected = 0
local currentInfected = 0
local goneToHospital = 0
local ballBounce = 1
local ballDensity = 1
local ballFriction = 0
local ballGravity = 0
local maskXStart = 0
local isMusicOn
local gameMode
local highScores = {}
local score = 0
local scaleUpMask = false
local scaleDownMask = false
local timerTimeLeft
local timerHospital
local moduleForce = 18000
local smallRectangleShape = {-50, 20, 50, 20, 50, -15, -50, -15}

-- * ui
local buttonMenu

-- * music
local bgMusic

local function onPressButtonMenu(event)
    physics.pause()
    -- Fermo i timer attivi quando il pulsante di menu viene premuto
    if timeLeft > 0 then
        timer.pause(timerTimeLeft)
    end
    if timeLeft > 5 then
        timer.pause(timerHospital)
    end
    composer.showOverlay(
        "gameMenu",
        {
            isModal = true,
            effect = "fromTop",
            time = 500
        }
    )
end

local function formatTime()
    local minutes = math.floor(timeLeft / 60)
    local seconds = timeLeft % 60
    return string.format("%01d:%02d", minutes, seconds)
end

function scene:create(event)
    local sceneGroup = self.view

    -- Recupero le variabili dal composer
    gameMode = composer.getVariable("gameMode")
    isMusicOn = composer.getVariable("soundOn")

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

    background = display.newImageRect(bg, "img/bg.png", 1180, 2020)

    -- * barriere
    topBarrier = display.newRect(fg, 0, 0, display.contentWidth, 1)
    physics.addBody(topBarrier, "static", {bounce = 1, friction = 0, density = 1.5, filter = utils.barrierFilter()})

    leftBarrier = display.newRect(fg, 0, 0, 1, display.contentHeight)
    physics.addBody(leftBarrier, "static", {bounce = 1, friction = 0, density = 1.5, filter = utils.barrierFilter()})

    rightBarrier = display.newRect(fg, 0, 0, 1, display.contentHeight)
    physics.addBody(rightBarrier, "static", {bounce = 1, friction = 0, density = 1.5, filter = utils.barrierFilter()})

    -- * elementi di gioco

    heart = display.newSprite(fg, heartSheet, BMSequence)
    heart.name = "heart"
    heart.sound = audio.loadSound("sounds/heart.wav")
    physics.addBody(heart, "static", {isSensor = true, filter = utils.bmFilter()})

    hospital = display.newSprite(fg, hospitalSheet, BMSequence)
    hospital.name = "hospital"
    hospital.sound = audio.loadSound("sounds/hospital.wav")
    physics.addBody(hospital, "static", {isSensor = true, filter = utils.bmFilter()})

    -- * inizializzazione persone
    local squareShape = {-70, 50, 70, 50, 70, -50, -70, -50}

    for i = 0, 6 do
        local face = display.newSprite(fg, faceSheet, faceSequence)
        face.isAlive = true
        face.isActive = true
        physics.addBody(
            face,
            "static",
            {shape = squareShape, bounce = 1, friction = 0, density = 1.5, filter = utils.maskFilter()}
        )
        table.insert(faces, face)
    end

    -- * inizializzazione maschera
    maskOutline = graphics.newOutline(1, "img/mask.png")
    mask = display.newImageRect(fg, "img/mask.png", 161, 53)

    -- Posizioni y per la maschera quando è piccola e quando è grande
    mask.yScaleUp = 1637
    mask.yScaleDown = 1657

    if gameMode == "tilt" then
        mask.width = 161
        mask.height = 53
        physics.addBody(
            mask,
            "static",
            {outline = maskOutline, bounce = 1, density = 1.5, friction = 0, filter = utils.maskFilter()}
        )
    elseif gameMode == "touch" then
        mask.width = mask.width / 100 * 60
        mask.height = mask.height / 100 * 60
        physics.addBody(
            mask,
            "static",
            {shape = smallRectangleShape, bounce = 1, friction = 0, density = 1.5, filter = utils.maskFilter()}
        )
    end
    mask.gravityScale = 500
    mask.isFixedRotation = true
    mask.isBullet = true

    ball = display.newImageRect(fg, "img/virus.png", 100, 100)
    ball.name = "ball"
    physics.addBody(
        ball,
        "dynamic",
        {radius = 50, bounce = ballBounce, density = ballDensity, friction = ballFriction, filter = utils.ballFilter()}
    )
    ball.gravityScale = ballGravity
    ball.isFixedRotation = true

    textTimeLeft = display.newText({parent = fg, text = formatTime(), font = utils.rubik(), fontSize = 180})
    textScore = display.newText({parent = fg, text = score, font = utils.rubik(), fontSize = 60})

    -- * UI
    buttonMenu =
        widget.newButton(
        {
            sheet = menuButtonSheet,
            defaultFrame = 1,
            overFrame = 2,
            onPress = onPressButtonMenu
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
    -- salvo in una variabile i punteggi migliori salvati in precedenza
    highScores = utils.getScores()
end

-- aggiorna la variabile del punteggio e il testo
local function updateScore(n)
    score = score + n
    textScore.text = score
end

local function handleGameEnd()
    -- setto la variabile che poi verrà letta dalla scena di menu
    if (goneToHospital == #faces) then
        composer.setVariable("gameMenuMode", "lose")
    else
        composer.setVariable("gameMenuMode", "win")
    end
    -- se la partita non è persa e il punteggio finale è maggiore del minore salvato allora aggiorno i punteggi
    if highScores[1] < score and goneToHospital < #faces then
        highScores[1] = score
        table.sort(highScores)
        utils.saveScores(highScores)
    end
    -- setto la variabile che poi verrà letta dalla scena di menu
    composer.setVariable("score", score)
    composer.showOverlay(
        "gameMenu",
        {
            isModal = true,
            effect = "fade",
            time = 500
        }
    )
end

-- A termine partite aggiungo n punti per oggi persona rimasta in gioco
local function updateEndScore()
    for index, face in ipairs(faces) do
        if (face.isActive and face.isAlive) then
            local textPoints = display.newText({text = "+25", fontSize = "50"})
            textPoints.x = face.x
            textPoints.y = face.y - 150
            transition.to(textPoints, {time = 3000, alpha = 0, y = textPoints.y - 50})
            updateScore(25)
        end
    end
end

-- Allo scadere del tempo fermo la musica e faccio partire le animazioni prima di terminare definitivamente il gioco
local function gameEnd()
    physics.pause()
    if timeLeft == 0 then
        transition.to(textTimeLeft, {time = 700, size = 500, y = display.contentCenterY})
    end
    timer.performWithDelay(1000, updateEndScore)

    audio.fadeOut({channel = 1, time = 5000})
    timer.performWithDelay(2500, handleGameEnd)
end

-- Ad ogni secondo aggiono il tempo rimanente e controllo che il timer non sia a 0. Se non ci sono persone infette aggiungo un +1
local function updateTime()
    timeLeft = timeLeft - 1
    textTimeLeft.text = formatTime()
    if currentInfected == 0 then
        updateScore(1)
    end
    if timeLeft == 0 then
        gameEnd()
    end
end

-- Ogni 5 secondi l'icona dell'ospedale entra ed esce dallo schermo
local function updateHospitalIcon()
    if hospital.x < display.contentWidth then
        transition.to(hospital, {time = 4500, alpha = 0, x = display.contentWidth + 500})
    else
        transition.to(hospital, {time = 500, alpha = 1, x = display.contentWidth - 105})
    end
end

-- Spawn di una pallina virus
local function spawnBall(pos)
    local ball = display.newImageRect(fg, "img/virus.png", 80, 80)
    physics.addBody(
        ball,
        "dynamic",
        {radius = 40, bounce = ballBounce, density = ballDensity, friction = ballFriction, filter = utils.virusFilter()}
    )
    -- la pallina avrà la stessa x della persona
    ball.x = pos
    ball.y = display.contentCenterY - 400
    ball.gravityScale = ballGravity
    -- la direzione viene scelta in modo casuale
    if (math.random(0, 1) > 0) then
        ball:applyForce(-8000, 10000, ball.x, ball.y)
    else
        ball:applyForce(8000, 10000, ball.x, ball.y)
    end
end

-- Si occupa di ingrandire la maschera
local function scaleUp()
    mask.width = 161
    mask.height = 53
    mask.y = mask.yScaleUp
    physics.removeBody(mask)
    physics.addBody(
        mask,
        "static",
        {outline = maskOutline, bounce = 1, density = 1.5, friction = 0, filter = utils.maskFilter()}
    )
    local vx, vy = ball:getLinearVelocity()
    local Fx = moduleForce * math.sin(math.atan(vx / vy))
    local Fy = moduleForce * math.cos(math.atan(vx / vy))
    ball:setLinearVelocity(0, 0)
    ball:applyForce(-Fx, -Fy, ball.x, ball.y)
end

-- Si occupa di rimpicciolire la maschera
local function scaleDown()
    mask.width = mask.width / 100 * 60
    mask.height = mask.height / 100 * 60
    physics.removeBody(mask)
    mask.y = mask.yScaleDown
    physics.addBody(
        mask,
        "static",
        {shape = smallRectangleShape, bounce = 1, friction = 0, density = 1.5, filter = utils.maskFilter()}
    )
    local vx, vy = ball:getLinearVelocity()
    local Fx = moduleForce * 2 * math.sin(math.atan(vx / vy))
    local Fy = moduleForce * 2 * math.cos(math.atan(vx / vy))
    ball:setLinearVelocity(0, 0)
    ball:applyForce(Fx, Fy, ball.x, ball.y)
end

-- Faccio partire la fisica, il virus e i timer
local function startGame()
    physics.start()
    if gameMode == "tilt" then
        ball:applyForce(18000, 18000, ball.x, ball.y)
    elseif gameMode == "touch" then
        ball:applyForce(18000 * 2, 18000 * 2, ball.x, ball.y)
    end
    -- Ad ogni secondo toglie un secondo dal tempo mancante
    timerTimeLeft = timer.performWithDelay(1000, updateTime, timeLeft)
    -- Ogni 5 secondi compare e scompare l'ospedale
    timerHospital = timer.performWithDelay(5000, updateHospitalIcon, timeLeft / 5 - 1)
end

local function onTouch(event)
    if (event.phase == "began") then
        maskXStart = mask.x
    end
    if (event.phase == "moved") then
        -- aggiorno la posizione della maschera rispetto alla sua posizione iniziale
        local offset = (event.xStart - event.x) * 2
        local position = maskXStart - offset
        -- controllo uscita dallo schermo
        if (position > display.contentWidth - mask.width / 3 * 2) then
            mask.x = display.contentWidth - mask.width / 3 * 2
        elseif (position < mask.width / 3 * 2) then
            mask.x = mask.width / 3 * 2
        else
            mask.x = position
        end
    end
end

local function onLocalCollisionFace(self, event)
    local face = self
    if (event.phase == "began") then
        -- se la persona non è in ospedale
        if face.isAlive then
            -- se la persona non è già infetta viene infettata
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
    elseif (event.phase == "ended") then
        if currentInfected == 1 and mask.y == mask.yScaleDown then
            scaleUpMask = true
        end
    end
end

local function sensorCollisionHospital(self, event)
    if (event.phase == "began") then
        updateScore(-10)
        local textPoints = display.newText({text = "-10", fontSize = "40"})
        textPoints.x = hospital.x - 100
        textPoints.y = hospital.y
        transition.to(textPoints, {time = 1000, alpha = 0})
        if isMusicOn then
            audio.play((self).sound, {channel = 3})
        end
        event.other:removeSelf()
        goneToHospital = goneToHospital + 1
        if goneToHospital == #faces then
            timer.pause(timerHospital)
            timer.pause(timerTimeLeft)
            gameEnd()
        end
        currentInfected = currentInfected - 1
        if currentInfected == 0 and mask.y == mask.yScaleUp then
            scaleDownMask = true
        end
        -- Cerco tra le persone una infetta da disattivare
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
        local textPoints = display.newText({text = "+8", fontSize = "40"})
        textPoints.x = heart.x + 100
        textPoints.y = heart.y
        transition.to(textPoints, {time = 1000, alpha = 0})
        if isMusicOn then
            audio.play((self).sound, {channel = 2})
        end
        currentInfected = currentInfected - 1
        event.other:removeSelf()
        if currentInfected == 0 and mask.y == mask.yScaleUp then
            scaleDownMask = true
        end
        -- Cerco tra le persone una infetta da far tornare sana
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

local function onUpdate()
    if gameMode == "touch" then
        if scaleUpMask then
            scaleUp()
            scaleUpMask = false
        elseif scaleDownMask then
            scaleDown()
            scaleDownMask = false
        end
    end
end

-- funzione utilizzata per la modalità tilt
local function onTilt(event)
    -- calcolo la posizione che deve avere la maschera rispetto alla larghezza dello schermo in base ai dati dell'accelerometro
    local position = display.contentCenterY / 2 + (event.xGravity * 5 * display.contentCenterY)
    -- controllo sull'uscita dallo schermo
    if (position > display.contentWidth - mask.width / 3 * 2) then
        mask.x = display.contentWidth - mask.width / 3 * 2
    elseif (position < mask.width / 3 * 2) then
        mask.x = mask.width / 3 * 2
    else
        mask.x = position
    end
end

-- Resume chiamato dall'overlay di menu
function scene:resumeGame()
    physics.start()
    timer.resume(timerTimeLeft)
    timer.resume(timerHospital)
end

function scene:show(event)
    local phase = event.phase

    if (phase == "will") then
        topBarrier.x = display.contentCenterX
        topBarrier.y = 0
        topBarrier.alpha = 0

        leftBarrier.x = 0
        leftBarrier.y = display.contentCenterY
        leftBarrier.alpha = 0

        rightBarrier.x = display.contentWidth
        rightBarrier.y = display.contentCenterY
        rightBarrier.alpha = 0

        background.x = display.contentCenterX
        background.y = display.contentCenterY

        -- dispongo le persone
        for index, face in ipairs(faces) do
            face.x = (index - 1) * 150 + 90
            face.y = display.contentHeight - 175
        end

        ball.x = display.contentCenterX
        ball.y = display.contentCenterY - 400

        mask.x = display.contentCenterX
        mask.y = mask.yScaleDown
        if gameMode == "tilt" then
            mask.y = mask.yScaleUp
        elseif gameMode == "touch" then
            mask.y = mask.yScaleDown
        else
        end

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

        buttonMenu.x = display.contentCenterX
        buttonMenu.y = 100
        audio.setVolume(0.1, {channel = 1})
        audio.setVolume(0.1, {channel = 2})
        audio.setVolume(0.1, {channel = 3})
    elseif (phase == "did") then
        if (gameMode == "touch") then
            Runtime:addEventListener("touch", onTouch)
        elseif (gameMode == "tilt") then
            Runtime:addEventListener("accelerometer", onTilt)
        end
        Runtime:addEventListener("enterFrame", onUpdate)
        heart.collision = sensorCollisionHeart
        heart:addEventListener("collision")

        hospital.collision = sensorCollisionHospital
        hospital:addEventListener("collision")

        for index, face in ipairs(faces) do
            face.collision = onLocalCollisionFace
            face:addEventListener("collision")
        end

        if (isMusicOn) then
            audio.play(bgMusic, {loops = -1, fadeIn = 2000, channel = 1})
        end

        startGame()
    end
end

function scene:hide(event)
    local phase = event.phase

    if (phase == "will") then
        physics.pause()
        Runtime:removeEventListener("enterFrame", onUpdate)
        heart:removeEventListener("collision")
        hospital:removeEventListener("collision")

        --timerTimeLeft = nil
        --timerHospital = nil
        if (gameMode == "touch") then
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

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene
