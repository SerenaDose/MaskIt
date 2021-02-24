-----------------------------------------------------------------------------------------
--
-- MaskIt -- menu scene
--
-----------------------------------------------------------------------------------------

-- Load libraries
local composer = require("composer")
local widget = require("widget")
local utils = require("utils")

local scene = composer.newScene()

-- Elementi della schermata
local background
local logo
local buttonPlay
local buttonInfo
local buttonScores
local buttonMusic
local textMusicState
local textGameModeState
local textButtonInfo
local textButtonScores

-- Variabili
local buttonisGameModeTouch
local gameMode = "touch"
local isMusicOn = "true"

local fontSize = 45

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

local function onPressButtonInfo(event)
	composer.showOverlay(
		"info",
		{
			effect = "fade",
			time = 400
		}
	)
end

local function onPressButtonScores(event)
	composer.showOverlay(
		"scores",
		{
			effect = "fade",
			time = 400
		}
	)
end

local function onPressButtonPlay(event)
	-- Setto le variabili prima di passare alla scena di gioco
	composer.setVariable("gameMode", gameMode)
	composer.setVariable("soundOn", isMusicOn)
	-- Salvo le preferenze per la prossima volta in cui verrà riaperta l'app
	if isMusicOn then
		utils.saveSoundPreferences(1)
	else
		utils.saveSoundPreferences(0)
	end
	composer.gotoScene(
		"intro",
		{
			effect = "fade",
			time = 400
		}
	)
end

local function onPressButtonMusic(event)
	-- Update stato e testo switch
	local switch = event.target
	if switch.isOn then
		textMusicState.text = "Music: on"
		isMusicOn = true
	else
		textMusicState.text = "Music: off"
		isMusicOn = false
	end
end

local function onPressButtonGameMode(event)
	-- Update stato e testo switch
	local switch = event.target
	if switch.isOn then
		textGameModeState.text = "Game mode: touch"
		gameMode = "touch"
	else
		textGameModeState.text = "Game mode: tilt"
		gameMode = "tilt"
	end
end

function scene:create(event)
	local sceneGroup = self.view

	local bg = display.newGroup()
	local fg = display.newGroup()

	local playButtonSheet = graphics.newImageSheet("img/ui/button-play.png", utils.optionsRectangularButtons())
	local infoButtonSheet = graphics.newImageSheet("img/ui/button-info.png", utils.optionsRoundedButtons())
	local scoresButtonSheet = graphics.newImageSheet("img/ui/button-scores.png", utils.optionsRoundedButtons())
	local musicButtonSheet = graphics.newImageSheet("img/ui/button-sound.png", utils.optionsChecboxButton())
	local gameModeButtonSheet = graphics.newImageSheet("img/ui/button-gameMode.png", utils.optionsChecboxButton())

	-- Inizializzazione elementi della scena
	background = display.newImageRect(bg, "img/bg-dark.png", 1180, 2020)
	logo = display.newImageRect(fg, "img/ui/logo.png", 699, 477)

	buttonPlay =
		widget.newButton(
		{
			sheet = playButtonSheet,
			defaultFrame = 1,
			overFrame = 2,
			onPress = onPressButtonPlay
		}
	)
	buttonInfo =
		widget.newButton(
		{
			sheet = infoButtonSheet,
			defaultFrame = 1,
			overFrame = 2,
			onPress = onPressButtonInfo
		}
	)
	buttonScores =
		widget.newButton(
		{
			sheet = scoresButtonSheet,
			defaultFrame = 1,
			overFrame = 2,
			onPress = onPressButtonScores
		}
	)
	buttonMusic =
		widget.newSwitch(
		{
			style = "checkbox",
			width = 119,
			height = 117,
			initialSwitchState = true,
			onPress = onPressButtonMusic,
			sheet = musicButtonSheet,
			frameOff = 2,
			frameOn = 1
		}
	)
	buttonisGameModeTouch =
		widget.newSwitch(
		{
			style = "checkbox",
			width = 119,
			height = 117,
			initialSwitchState = true,
			onPress = onPressButtonGameMode,
			sheet = gameModeButtonSheet,
			frameOff = 2,
			frameOn = 1
		}
	)

	textGameModeState =
		display.newText({parent = fg, text = "Game mode: touch", font = utils.garamond(), fontSize = fontSize})
	textButtonInfo = display.newText({parent = fg, text = "Info", font = utils.garamond(), fontSize = fontSize})
	textButtonScores = display.newText({parent = fg, text = "Scores", font = utils.garamond(), fontSize = fontSize})

	-- Se il file settings.txt non è presente significa che il gioco viene giocato per la prima volta,
	-- quindi mostro le istruzioni nella prossima scena, altrimenti no
	if (utils.fileExists("settings.txt")) then
		composer.setVariable("showInstructions", "0")
	else
		composer.setVariable("showInstructions", "1")
	end
	-- Recupero dal file settings le preferenze riguardanti l'audio e aggiorno le variabili
	local wasLastTimeSoundOn = utils.wasLastTimeSoundOn()
	if wasLastTimeSoundOn then
		buttonMusic:setState({isOn = true})
		textMusicState = display.newText({parent = fg, text = "Music: on", font = utils.garamond(), fontSize = fontSize})
		isMusicOn = true
	else
		buttonMusic:setState({isOn = false})
		textMusicState = display.newText({parent = fg, text = "Music: off", font = utils.garamond(), fontSize = fontSize})
		isMusicOn = false
	end

	sceneGroup:insert(bg)
	sceneGroup:insert(fg)
	sceneGroup:insert(buttonisGameModeTouch)
	sceneGroup:insert(buttonInfo)
	sceneGroup:insert(buttonMusic)
	sceneGroup:insert(buttonPlay)
	sceneGroup:insert(buttonScores)
end

-- show()
function scene:show(event)
	local phase = event.phase

	if (phase == "will") then
		background.x = display.contentCenterX
		background.y = display.contentCenterY

		buttonPlay.x = display.contentCenterX
		buttonPlay.y = display.contentHeight - 200

		buttonInfo.x = 118
		buttonInfo.y = 118

		buttonScores.x = display.contentWidth - 118
		buttonScores.y = 118

		logo.x = display.contentCenterX - 10
		logo.y = 600

		buttonMusic.x = display.contentCenterX
		buttonMusic.y = display.contentCenterY + 100

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
	elseif (phase == "did") then
		composer.removeScene("game")
	end
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)

return scene
