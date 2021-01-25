local M = {}

function M.optionsRectangularButtons()
    return {
	    width = 573,
        height = 261,
        numFrames = 2,
    }
end

function M.optionsRoundedButtons()
    return {
        width = 119,
        height = 119,
        numFrames = 2,
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
    return {categoryBits = 1, maskBits= 38}
end

function M.ballFilter()
    return {categoryBits = 2, maskBits= 29}
end

function M.virusFilter()
    return {categoryBits = 32, maskBits= 13}
end

function M.maskFilter()
    return {categoryBits = 4, maskBits= 43}
end

function M.faceFilter()
    return {categoryBits = 8, maskBits= 38}
end

function M.bmFilter()
    return {categoryBits = 16, maskBits= 2}
end

return M