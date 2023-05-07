local levelCompletePraises = {"NICE JOB!", "GREAT!", "AMAZING!","EXCEPTIONAL!"}



local jsonUtils = require("jsonUtils")
local file = require("fileFunctions")
local widget = require("widget")
local composer = require "composer" 
-- local ads = require("ads")

local dictionaryFunction = jsonUtils.init({jsonFileName = "words.json", path = system.ResourceDirectory})
local dictionary = dictionaryFunction:load().words 

local scene = composer.newScene()


local centerX = display.contentCenterX
local centerY = display.contentCenterY
local _W = display.contentWidth
local _H = display.contentHeight

local boxSize = 70 
local boxGap = 10 
local cornerRadius = 10
local font = "Century Gothic"


--objects 
local gameObjects 
local letterGroup 
local letters 
local containerGroup, puzzleNoDisplay, containers, markers, markerGroup

--functions 
local onTouch,createLevel,shuffleString,shufflePuzzle

--helpful functions **can be transfered to a utilities module sometime in the future  
local function distBetween( x1, y1, x2, y2 ) --gets distance between two points 
   local xFactor = x2 - x1
   local yFactor = y2 - y1
   local dist = math.sqrt( (xFactor*xFactor) + (yFactor*yFactor) )
   return dist
end

local function breath(obj,delay,time,increase)
	transition.to(obj,{time=time,delay=delay,xScale=increase,yScale=increase,onComplete = function(obj) 
		transition.to(obj,{time=time,delay=delay,xScale=1,yScale=1,onComplete = function(obj) 
			breath(obj,delay,time,increase)
		end}) 
	end})

end 

function shuffleString(inputStr)
	local outputStr = "";
	local strLength = string.len(inputStr);
	
	while (strLength ~=0) do
		--get a random character of the input string
		local pos = math.random(strLength);
		
		--insert into output string
		outputStr = outputStr..string.sub(inputStr,pos,pos);
		
		--remove the used character from input string
		inputStr = inputStr:sub(1, pos-1) .. inputStr:sub(pos+1);
		
		--get new length of the input string
		strLength = string.len(inputStr);
	end
	
	return outputStr;
end


function shufflePuzzle(puzzle)
	local fullString = ""
	
	for i=1,#puzzle do 
		for k=1,#puzzle[i] do 
			fullString = fullString..string.sub(puzzle[i],k,k)
		end 
	end 
	print(fullString)
	
	
	return shuffleString(fullString)
end 

function scene.scanForWords()

		
		local lettersArray = {} 
		
		for i=1,#letters do 
			lettersArray[letters[i].i] = letters[i].letter.text
		end 
		
		local words = {} 
		local correctWordsCount = 0 
		for i=1,3 do 
			words[i] = ""
			for k=1,3 do 
				words[i] = words[i]..lettersArray[(i-1)*3+k]
			end 
			--check on the database if the words exist 
			if dictionary[words[i]] ~= nil then 
				correctWordsCount = correctWordsCount + 1 
				for k=1,3 do 	
					for j=1,#letters do 
						if letters[j].i == (i-1)*3+k then 
							letters[j].shape:setFillColor(unpack(colorPalette.dark))
							letters[j].letter:setFillColor(unpack(colorPalette.primary))
						end 
					end 
					
				end 
				markers[i].cross.alpha = 0 
				markers[i].check.alpha = 1 
			else 
				for k=1,3 do 
					for j=1,#letters do 
						if letters[j].i == (i-1)*3+k then 
							letters[j].shape:setFillColor(unpack(colorPalette.primary))	
							letters[j].letter:setFillColor(unpack(colorPalette.light))
						end 
					end 
				end 
				markers[i].cross.alpha = 1 
				markers[i].check.alpha = 0 
			end 
		end 
		
		if correctWordsCount == 3 then 
			print("Well done!")
			
			for i=1,#letters do 
				letters[i]:removeEventListener( "touch", onTouch )
			end 
			
			local previousLevel = gameDataTable.currentLevel
			local unlockedLevel = 0
			
			if gameDataTable.currentLevel + 1 > #gameDataTable.levels then 
				print("maximum level reached. Till next update! :)")
			else 
			
				--mark level as "done"
				if gameDataTable.levels[gameDataTable.currentLevel].status == "unlocked" then 
					gameDataTable.levels[ gameDataTable.currentLevel].status = "done"
					
					--unlock a new level (first locked level to encounter)
					for i=1,#gameDataTable.levels do 
						if gameDataTable.levels[i].status == "locked" then 
							gameDataTable.levels[i].status = "unlocked"
							unlockedLevel = i 
							break 
						end 
					end 
					
				end 
				
				--goto next level 
				for i=gameDataTable.currentLevel+1,#gameDataTable.levels do 
					if gameDataTable.levels[i].status == "unlocked" then 
						gameDataTable.currentLevel = i 
						break 
					end 
				end 
	
				
				gameData:save(gameDataTable)


				local newLevel = display.newGroup() 
				newLevel.anchorChildren = true 
				
				gameObjects:insert(newLevel)
				
							
				local function handleButtonEvent(event)
					if event.phase == "ended" then 
						if event.target.id == "next" then 
							scene.createLevel()
							display.remove(newLevel)
							newLevel = nil 
							
						elseif event.target.id == "facebook" then 
							system.openURL( "http://on.fb.me/1QUoO4z" )
						else 
							local options =
							{
							   supportedAndroidStores = { "google", "amazon" }
							}
							native.showPopup( "appStore", options )
						end 
					end 
				end 
				
				gamePlayCounter = gamePlayCounter + 1 
				
				if gamePlayCounter >= adsFrequency then 
					-- if  ads.isLoaded("interstitial") then 
					-- 	gamePlayCounter = 0 
					-- 	ads.show("interstitial",{appId=admob_interstitial})
					-- 	ads.load("interstitial",{appId=admob_interstitial})
					-- end 
				end 
				
				transition.to(letterGroup,{delay=500,alpha=0,time=500,onComplete = function() 
				
				
					local newLevelbackground = display.newRect(newLevel,centerX,centerY,_W,_H)
					newLevelbackground:setFillColor(unpack(colorPalette.background))
					newLevelbackground.alpha = 0.9
					
					local congratulations = display.newText(newLevel,levelCompletePraises[math.random(1,#levelCompletePraises)],centerX,60,font,25)
					congratulations:setFillColor(unpack(colorPalette.light))
					
					local ribbons = display.newImageRect(newLevel,"res/ribbons.png",344*0.3,212*0.3)
					ribbons.x, ribbons.y = centerX,centerY - 70  
					
					local y = ribbons.y + ribbons.contentHeight/2 + 30  
					local x = centerX - 80
					for i=1,#words do 
						local word = display.newText(newLevel,words[i],x,y,font,25)
						x = x + 80 
					end 
					
					local button_next = widget.newButton
					{
						id = "next",
						width = 396*0.3,
						height = 174*0.3,
						defaultFile = "res/next.png",
						overFile = "res/next.png",
						x = centerX,
						y = centerY + 150,
						onEvent = handleButtonEvent
					}
					newLevel:insert(button_next)
					
					local levelDone = display.newText(newLevel,"PUZZLE "..previousLevel.." IS SOLVED!",centerX,congratulations.y + 30,font,15)
					levelDone:setFillColor(unpack(colorPalette.light))
					if unlockedLevel ~= 0 then 
						local levelUnlocked = display.newText(newLevel,"PUZZLE "..unlockedLevel.." UNLOCKED",centerX,levelDone.y + levelDone.contentHeight/2 + 10,font,15)
						levelUnlocked:setFillColor(unpack(colorPalette.light))
					end 
					
					--show promotional stuff 
					if 1 == math.random(1,3) then 
					
						local bar = display.newRect(newLevel,centerX,y + 25 + 35,_W,35)
						bar:setFillColor(unpack(colorPalette.light))
						
						if 1 == math.random(1,2) then 
						
							local button_promo = widget.newButton
							{
								id = "facebook",
								width = 100*0.3,
								height = 86*0.3,
								defaultFile = "res/like.png",
								overFile = "res/like.png",
								x = bar.x,
								y = bar.y,
								onEvent = handleButtonEvent,
								label = "Visit BlueboxLab",
								font = font,
								fontSize = bar.contentHeight/2 ,
								labelColor = { default= {unpack(colorPalette.dark)}, over={ 0, 0, 0, 0.5 } },
								labelAlign = "left",
								labelXOffset = 30
							}
							newLevel:insert(button_promo)
						else
							local button_promo = widget.newButton
							{
								id = "rate",
								width = 128*0.25,
								height = 127*0.25,
								defaultFile = "res/rate.png",
								overFile = "res/rate.png",
								x = bar.x,
								y = bar.y,
								onEvent = handleButtonEvent,
								label = "Rate Us",
								font = font,
								fontSize = bar.contentHeight/2 ,
								labelColor = { default= {unpack(colorPalette.dark)}, over={ 0, 0, 0, 0.5 } },
								labelAlign = "left",
								labelXOffset = 30
							}
							newLevel:insert(button_promo)
						end 
					end 
				
		
					newLevel.x,newLevel.y = centerX,centerY
				end })
				
				
			end 
		end 

	end 

function scene.createLevel()
	--local words = {"LEG","ROW","HEN"}
	--local puzzle = shufflePuzzle(words)
	--print(puzzle)
	
	
	local puzzle = shufflePuzzle(gameDataTable.levels[gameDataTable.currentLevel].words)
	puzzleNoDisplay.text = "PUZZLE "..gameDataTable.currentLevel
	
	--clean previous level 
	display.remove(letterGroup)
	letterGroup = nil 
	
	display.remove(markerGroup)
	markerGroup = nil 
	

	
	letterGroup = display.newGroup() 
	gameObjects:insert(letterGroup)
	
	letterGroup.anchorChildren = true 
	letterGroup.x,letterGroup.y = containerGroup.x,containerGroup.y 
	letters = {} 
	
	for i=1,string.len(puzzle) do 
		letters[i] = display.newGroup()
		letters[i].anchorChildren = true 
		
		local shape = display.newRoundedRect(letters[i],boxSize/2,boxSize/2,boxSize,boxSize,cornerRadius)
		shape:setFillColor(unpack(colorPalette.primary))
		letters[i].shape = shape 
		
		local letter = display.newText(letters[i],string.sub(puzzle,i,i),boxSize/2,boxSize/2,font,boxSize/2)
		letter:setFillColor(unpack(colorPalette.light))
		letters[i].letter = letter 
		
		
		letters[i].x,letters[i].y = containers[i].x,containers[i].y 
		
		letters[i].i = i --to know what container is associated with them 
		--letters[i].
		
		letters[i]:addEventListener( "touch", onTouch )
		
		letterGroup:insert(letters[i])
		
	end 
	
	
	markerGroup = display.newGroup()
	markerGroup.anchorChildren = true 
	gameObjects:insert(markerGroup)
	markers = {} 
	
	for i=1,3 do 
		markers[i] = display.newGroup()
		markers[i].anchorChildren = true 
		
		local check = display.newImageRect(markers[i],"res/check-white.png",64*0.3,57*0.3)
		check.x, check.y = 16,16
		markers[i].check = check
		
		
		local cross = display.newImageRect(markers[i],"res/cross-white.png",64*0.3,64*0.3)
		cross.x, cross.y = 16,16
		markers[i].cross = cross 
		
		markers[i].x, markers[i].y = 16,containers[i*3].y  
		
		markerGroup:insert(markers[i])
	end 
	
	markerGroup.x, markerGroup.y = containerGroup.x + containerGroup.contentWidth/2 +20, containerGroup.y
	
	scene.scanForWords()
end 

function scene:create( event )

    local sceneGroup = self.view
	gameObjects = display.newGroup()
	
	
    -- Initialize the scene here
    -- Example: add display objects to "sceneGroup", add touch listeners, etc.
	

	local background = display.newRect(sceneGroup,centerX,centerY,_W,_H)
	background:setFillColor(unpack(colorPalette.background))
	
	
	
	puzzleNoDisplay = display.newText(gameObjects,"PUZZLE "..gameDataTable.currentLevel,centerX,40,font,20)
	puzzleNoDisplay:setFillColor(unpack(colorPalette.light))
	
	
	
	--containers
	containerGroup = display.newGroup() 
	gameObjects:insert(containerGroup) 

	containerGroup.anchorChildren = true 
	containerGroup.x, containerGroup.y = centerX,centerY - 30
	 
	containers = {} 

	local x = boxSize/2 
	local y = boxSize/2 

	for i=1,3 do 
		for k=1,3 do 
			containers[#containers+1] = display.newRoundedRect(containerGroup,x,y,boxSize+6,boxSize+6,cornerRadius+1)
			x = x + boxGap + boxSize
		end 
		x = boxSize/2
		y = boxSize + boxGap + y 
	end 

	containerGroup.alpha = 0.1
	
	--gameObjects:insert(letterGroup)
	
	local function handleButtonEvent(event)
		if event.phase == "ended" then 
			if event.target.id == "settings" then 
				composer.showOverlay("scSettings",{isModal = true})
			elseif event.target.id == "levels" then 
				composer.gotoScene("scLevels")--,{isModal = true})
			elseif event.target.id == "shuffle" then 
				scene.createLevel()
			elseif event.target.id == "sharePuzzle" then 
			
				display.save( sceneGroup, "snap.png", system.CachesDirectory)
			
				local serviceName = "facebook"
				local msg = ""
				
				local isAvailable = native.canShowPopup( "social", serviceName )
				
				if isAvailable then
					print("Social popup is available, serviceName: ",serviceName)
					local listener = {}
					
					function listener:popup( event )
						print( "name(" .. event.name .. ") type(" .. event.type .. ") action(" .. tostring(event.action) .. ") limitReached(" .. tostring(event.limitReached) .. ")" )			
					end

					-- Show the popup
					native.showPopup( "social",
					{
						service = serviceName, -- The service key is ignored on Android.
						message = msg,
						listener = listener,
						image = 
						{
							{ filename = "snap.png", baseDir = system.CachesDirectory },
						},
						url = 
						{ 
							""
						}
					})
				else
					if "simulator" == system.getInfo( "environment" ) then
						native.showAlert( "Build for device", "This plugin is not supported on the Corona Simulator, please build for an iOS/Android device or the Xcode simulator", { "OK" } )
					else
						-- Popup isn't available.. Show error message
						native.showAlert( "Cannot send " .. serviceName .. " message.", "Please setup your " .. serviceName .. " account or check your network connection", { "OK" } )
					end
				end
			end 
		end 
	end 

	local button_settings = widget.newButton
	{
		id = "settings",
		width = 128*0.3,
		height = 127*0.3,

		defaultFile = "res/settings.png",
		overFile = "res/settings.png",
		x = _W - 30 ,
		y = 40,
		onEvent = handleButtonEvent,
	}
	sceneGroup:insert(button_settings)  
	
	-- local button_sharePuzzle = widget.newButton
	-- {
	-- 	id = "sharePuzzle",
	-- 	width = 128*0.35,
	-- 	height = 127*0.35,
	-- 	defaultFile = "res/sharePuzzle.png",
	-- 	overFile = "res/sharePuzzle.png",
	-- 	x = centerX - 50 ,
	-- 	y = containerGroup.y + containerGroup.contentHeight/2 + 60,
	-- 	onEvent = handleButtonEvent,	
	-- }
	-- sceneGroup:insert(button_sharePuzzle) 
	
	local button_levels = widget.newButton
	{
		id = "levels",
		width = 128*0.35,
		height = 127*0.35,
		defaultFile = "res/levels.png",
		overFile = "res/levels.png",
		x = centerX + 30 ,
		y = containerGroup.y + containerGroup.contentHeight/2 + 60,
		onEvent = handleButtonEvent,	
	}
	sceneGroup:insert(button_levels) 

	local button_shuffle = widget.newButton
	{
		id = "shuffle",
		width = 128*0.35,
		height = 127*0.35,
		defaultFile = "res/shuffle.png",
		overFile = "res/shuffle.png",
		x = centerX - 30,
		y = containerGroup.y + containerGroup.contentHeight/2 + 60,
		onEvent = handleButtonEvent,		
	}
	sceneGroup:insert(button_shuffle)

	
	
	sceneGroup:insert(gameObjects)

	function onTouch( event )
		local t = event.target
		local phase = event.phase

		if "began" == phase then
			-- Make target the top-most object
			local parent = t.parent
			parent:insert( t )
			display.getCurrentStage():setFocus( t )
			
			-- Spurious events can be sent to the target, e.g. the user presses 
			-- elsewhere on the screen and then moves the finger over the target.
			-- To prevent this, we add this flag. Only when it's true will "move"
			-- events be sent to the target.
			t.isFocus = true
			t.xScale,t.yScale = 0.7,0.7 
			
			-- Store initial position
			t.x0 = event.x - t.x
			t.y0 = event.y - t.y
		elseif t.isFocus then
			if "moved" == phase then
				-- Make object move (we subtract t.x0,t.y0 so that moves are
				-- relative to initial grab point, rather than object "snapping").
				t.x = event.x - t.x0
				t.y = event.y - t.y0
				
				--[[ not needed for now 
				-- Gradually show the shape's stroke depending on how much pressure is applied.
				if ( event.pressure ) then
					t:setStrokeColor( 1, 1, 1, event.pressure )
				end
				--]]
				
				for i=1,#letters do 
					if distBetween(letters[i].x,letters[i].y,t.x,t.y) < boxSize/2 + boxGap then 
						if letters[i] ~= t and i ~= letterGroup.toSwap then 
							transition.to(letters[i],{time=100,xScale=0.8,yScale=0.8})
							
							if letterGroup.toSwap ~= nil then 
								transition.cancel(letters[letterGroup.toSwap])
								letters[letterGroup.toSwap].xScale,letters[letterGroup.toSwap].yScale = 1,1 
							end 
							
							letterGroup.toSwap = i 
							break 
						end 
					else 
						if letters[letterGroup.toSwap] ~= nil then 
							transition.cancel(letters[letterGroup.toSwap])
							letters[letterGroup.toSwap].xScale,letters[letterGroup.toSwap].yScale = 1,1 
							letterGroup.toSwap = nil 
						end 
					end 
				end 
				
				
			elseif "ended" == phase or "cancelled" == phase then
				
				--find nearest container 
				local found = false 
				for i=1,#containers do 
					if distBetween(containers[i].x,containers[i].y,t.x,t.y) < boxSize/2 + boxGap then 
							
						--look for the letter in the container
						local j 
						for k = 1,#letters do 
							if letters[k].i == i then 
								j  = k 
								break 
							end 
						end 

							transition.to(letters[j],{time=200,xScale=1,yScale=1,x=containers[t.i].x,y=containers[t.i].y,onComplete = function() 
						
								local swappedI = letters[j].i 
								letters[j].i = t.i 
								
								t.i = swappedI 
								scene.scanForWords()
							end })
					
						transition.to(t,{time=200,xScale=1,yScale=1,x =containers[i].x,y=containers[i].y })
							
						found = true 
						break 
					end 
				end 
				if not found then 
					transition.to(t,{time=200,xScale=1,yScale=1,x =containers[t.i].x,y=containers[t.i].y })
				end 
			
				display.getCurrentStage():setFocus( nil )
				t.isFocus = false
				
				
				
			end
		end

		-- Important to return true. This tells the system that the event
		-- should not be propagated to listeners of any objects underneath.
		return true
	end




end

-- "scene:show()"
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is still off screen (but is about to come on screen)
    elseif ( phase == "did" ) then
        -- Called when the scene is now on screen
        -- Insert code here to make the scene come alive
        -- Example: start timers, begin animation, play audio, etc.
		
		local previousScene = composer.getSceneName( "previous" )
		if previousScene ~= nil then 
			composer.removeScene( previousScene )
		end 
		
		self.createLevel()
		-- ads:setCurrentProvider( "admob" )
		-- ads.show("banner",{x=0,y=100000, appId=admob_bannerAppID})
		
		-- print("Admob: Try to load fullscreen ad for gameOver scene")
		-- ads.load("interstitial",{appId=admob_interstitial})
		
		
    end
end

-- "scene:hide()"
function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is on screen (but is about to go off screen)
        -- Insert code here to "pause" the scene
        -- Example: stop timers, stop animation, stop audio, etc.
    elseif ( phase == "did" ) then
        -- Called immediately after scene goes off screen
    end
end


-- "scene:destroy()"
function scene:destroy( event )

    local sceneGroup = self.view

    -- Called prior to the removal of scene's view
    -- Insert code here to clean up the scene
    -- Example: remove display objects, save state, etc.
end


-- -------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-- -------------------------------------------------------------------------------

return scene

