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
    return {categoryBits = 1, maskBits= 34}
end

function M.maskBarrierFilter()
    return {categoryBits = 64, maskBits= 4}
end

function M.ballFilter()
    return {categoryBits = 2, maskBits= 29}
end

function M.virusFilter()
    return {categoryBits = 32, maskBits= 13}
end

function M.maskFilter()
    return {categoryBits = 4, maskBits= 98}
end

function M.faceFilter()
    return {categoryBits = 8, maskBits= 34}
end

function M.bmFilter()
    return {categoryBits = 16, maskBits= 2}
end

function M.getScores()
	local path = system.pathForFile( "scores.txt", system.DocumentsDirectory )
	-- Open the file handle
	local file, errorString = io.open( path, "r" )
	if not file then
	-- Error occurred; output the cause
		print( "File error: " .. errorString )
		local file, errorString = io.open( path, "w" )
		print("create new file")
		file:write( "6 9 2" )
		io.close( file )
	end
	file = nil
	local file, errorString = io.open( path, "r" )
	local scores={}
	for i = 1,3 do 			
		local n = file:read("*n")
		print("Numero trovato"..n)
		table.insert(scores, n)
		print(scores)
	end

    table.sort(scores)
    for i = 1,3 do 	
        print("b")		
		print(scores[i])
    end
    return scores
end

function M.saveScores(scores)
    print("sddsfdfsdf")
print(scores)
for i = 1,3 do 	
    print("b")		
    print(scores[i])
end
end

return M