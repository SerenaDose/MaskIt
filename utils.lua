local M = {}

function M.optionsRectangularButtons()
    return {
        width = 573,
        height = 261,
        numFrames = 2
    }
end

function M.optionsRoundedButtons()
    return {
        width = 119,
        height = 119,
        numFrames = 2
    }
end

function M.optionsChecboxButton()
    return {
        width = 100,
        height = 100,
        numFrames = 2,
        sheetContentWidth = 200,
        sheetContentHeight = 100
    }
end

function M.barrierFilter()
    return {categoryBits = 1, maskBits = 18}
end

function M.ballFilter()
    return {categoryBits = 2, maskBits = 5}
end

function M.virusFilter()
    return {categoryBits = 16, maskBits = 13}
end

function M.maskFilter()
    return {categoryBits = 4, maskBits = 18}
end

function M.bmFilter()
    return {categoryBits = 8, maskBits = 16}
end

function M.rubik()
    return "font/Rubik-Light.ttf"
end

function M.garamond()
    return "font/CormorantGaramond-Regular.ttf"
end

-- Recupera i punteggi dal file scores.txt, se non esiste lo crea mettendo 3 punteggi 0
function M.getScores()
    local path = system.pathForFile("scores.txt", system.DocumentsDirectory)

    local file, errorString = io.open(path, "r")
    if not file then
        print("File error: " .. errorString)
        local file, errorString = io.open(path, "w")
        print("creating new file")
        file:write("0 0 0")
        io.close(file)
    end
    file = nil
    local file, errorString = io.open(path, "r")
    local scores = {}
    for i = 1, 3 do
        local n = file:read("*n")
        table.insert(scores, n)
    end

    table.sort(scores)
    for i = 1, 3 do
    end
    return scores
end

-- Salva i punteggi sovrascrivendo quelli esistenti
function M.saveScores(scores)
    local path = system.pathForFile("scores.txt", system.DocumentsDirectory)
    local file, errorString = io.open(path, "w")
    for i = 1, 3 do
        local n = " " .. scores[i]
        file:write(n)
    end
    io.close(file)
end
-- Legge la variabile all'interno del file settings.txt, se non esiste lo crea e salva l'attuale preferenza
function M.wasLastTimeSoundOn()
    local path = system.pathForFile("settings.txt", system.DocumentsDirectory)

    local file, errorString = io.open(path, "r")
    if not file then
        print("File error: " .. errorString)
        local file, errorString = io.open(path, "w")
        file:write("1")
        io.close(file)
    end
    file = nil
    local file, errorString = io.open(path, "r")
    local isSoundOn = file:read("*n")

    if (isSoundOn == 1) then
        return true
    else
        return false
    end
end
-- Salva la preferenza sull'audio
function M.saveSoundPreferences(isMmusicOn)
    local path = system.pathForFile("settings.txt", system.DocumentsDirectory)
    local file, errorString = io.open(path, "w")
    file:write(isMmusicOn)
    io.close(file)
end
-- Verifica se un file esiste
function M.fileExists(fileName)
    local path = system.pathForFile(fileName, system.DocumentsDirectory)
    local file, errorString = io.open(path, "r")
    if not file then
        return false
    else
        io.close(file)
        return true
    end
end

return M
