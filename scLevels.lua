local composer = require( "composer" )
local widget = require("widget")
-- local ads = require("ads")

local scene = composer.newScene()

local centerX = display.contentCenterX
local centerY = display.contentCenterY
local _W = display.contentWidth
local _H = display.contentHeight

local pickedLevel = 1 
local levelsDisplay = {}

function scene.unlockLevel()
	gameDataTable.levels[pickedLevel].status = "unlocked"
	levelsDisplay[pickedLevel].box:setFillColor(unpack(colorPalette.dark))
	levelsDisplay[pickedLevel].lock.alpha = 0 
	gameData:save(gameDataTable)
	composer.showOverlay("scMessage",{isModal = true, params = {header="UNLOCKED!",icon="res/unlocked.png",body="Thanks for watching.\nYou have unlocked puzzle "..pickedLevel}})
end 

function scene:create( event )
	local sceneGroup = self.view
	
	local background = display.newRect(sceneGroup,centerX,centerY,_W,_H)
	background:setFillColor(0,0,0,0.95)
	
	local function handleButtonEvent(event)
		if event.phase == "ended" then 
		
			if event.target.id == "close" then 
				 
				--composer.hideOverlay()
				composer.gotoScene("scGameScreen")
			end 
		end 
	end 
	
	local title = display.newText(sceneGroup,"PUZZLES",centerX,40,font,25)
	title:setFillColor(unpack(colorPalette.light))
	
	local back_button = widget.newButton
	{
		id = "close",
		width = 128*0.30,
		height = 127*0.30,
		defaultFile = "res/exit.png",
		overFile = "res/exit.png",
		x = 40,
		y = 40,
		onEvent = handleButtonEvent		
	}
	sceneGroup:insert(back_button)
	
	local function scrollListener( event )
		return true
	end



	local function scrollListener(event)
	end 
	
	local scrollView = widget.newScrollView
	{
		x = centerX,
		y = back_button.y + back_button.contentHeight/2 + 30,
		width = 245,
		height = _H-140,
		listener = scrollListener,
		backgroundColor = { 0.8, 0.8, 0.8, 0 },
		isBounceEnabled = true,
		horizontalScrollDisabled = true 
	}
	scrollView.anchorY = 0 
	sceneGroup:insert(scrollView)
	
	
	local boxSize = 50
	local cornerRadius = 6
	local gap = 15
	
	local x,y = boxSize/2,boxSize/2   
	
	levelsDisplay = {} 
	

	
	local function selectLevel(event)
	
	
		local t = event.target
		local phase = event.phase
		
		if phase == "began" then 
			-- Make target the top-most object
			local parent = t.parent
			parent:insert( t )
			display.getCurrentStage():setFocus( t )
						
			t.isFocus = true

		
		elseif t.isFocus then 
			if "moved" == phase then 
				if ( event.pressure ) then
					t:setStrokeColor( 1, 1, 1, event.pressure )
				else 
					t.isFocus = false 
					scrollView:takeFocus( event )
				end
				
			elseif "ended" == phase or "cancelled" == phase then
				
				if "ended" == phase then 
					print("id",t.id)
					print(gameDataTable.levels[t.id].status)
					if gameDataTable.levels[t.id].status == "locked" then 
					
					
						local function showVungleAd()
							-- ads:setCurrentProvider( "vungle" )
							if "simulator" ~= system.getInfo("environment") then 
							-- 	if ( ads.isAdAvailable() ) then
							-- 		pickedLevel = t.id 
							-- 		ads.show( "incentivized" )
							-- 	else
							-- 		timer.performWithDelay(500,function()
							-- 			composer.showOverlay("scMessage",{isModal = true, params = {header="NO AD AVAILABLE",
							-- 			body="Please check your internet connection and try again."}})
							-- 			end 
							-- 			)
							-- 	end 
							else 
								print("function was called")
								--testing unlock 
								pickedLevel = t.id 
								scene.unlockLevel()
								composer.showOverlay("scMessage",{isModal = true, params = {header="NO AD AVAILABLE",body="Please check your internet connection and try again."}})
							end 
						end 
						
						-- composer.showOverlay("scMessage",{isModal = true,params = {header="LOCKED",body="This puzzle is locked.\nWould you like to watch an ad to unlock it?",
						-- 	messageType = "question", icon = "res/lock-black.png",okFunction = showVungleAd,okButton = "res/rewardedYes.png"}})

					else
						--load level 
						gameDataTable.currentLevel = t.id 
						gameData:save(gameDataTable)
						composer.gotoScene("scGameScreen")
						--local gameScreen = composer.getScene( "scGameScreen" )						
						--gameScreen.createLevel()
						--composer.hideOverlay()
					end 
					
				end 
				
				t.isFocus = false 
				display.getCurrentStage():setFocus( nil )
			end 
		end 
		return true 
	end 
	
	for i=1,#gameDataTable.levels do 
		
		levelsDisplay[i] = display.newGroup()
		levelsDisplay[i].anchorChildren = true 
		
		levelsDisplay[i].id = i 
		local box = display.newRoundedRect(levelsDisplay[i],boxSize/2,boxSize/2,boxSize,boxSize,cornerRadius)
		levelsDisplay[i].box = box 
		local levelNumber = display.newText(levelsDisplay[i],i,box.x,box.y,font,boxSize/2)
		levelsDisplay[i].levelNumber = levelNumber
		levelNumber:setFillColor(unpack(colorPalette.light))
		local marker 
		if i == gameDataTable.currentLevel then 
			box:setFillColor(unpack(colorPalette.complement))
			if gameDataTable.levels[i].status == "done" then 
				local check = display.newImageRect(levelsDisplay[i],"res/check-white.png",64*0.25,57*0.25)
				check.x,check.y = boxSize-9,boxSize-9
			end 
			marker = display.newImageRect("res/up.png",64*0.3,40*0.3)
			
		elseif gameDataTable.levels[i].status == "done" then 
			local check = display.newImageRect(levelsDisplay[i],"res/check-white.png",64*0.25,57*0.25)
			check.x,check.y = boxSize-9,boxSize-9
			box:setFillColor(unpack(colorPalette.primary))
		elseif gameDataTable.levels[i].status == "unlocked" then 
			box:setFillColor(unpack(colorPalette.dark))
		else --"locked"
			box:setFillColor(unpack(colorPalette.dark))
			local lock = display.newImageRect(levelsDisplay[i],"res/lock-white.png",85*0.3,85*0.3)
			lock.x,lock.y = boxSize/2,boxSize/2
			levelsDisplay[i].lock = lock 		
			levelNumber:setFillColor(unpack(colorPalette.light))
			levelNumber.alpha = 0.5 
		end 
		
		levelsDisplay[i].x,levelsDisplay[i].y = x,y 
		scrollView:insert(levelsDisplay[i]) 
		
		if marker then 
			marker.x,marker.y = levelsDisplay[i].x,levelsDisplay[i].y+levelsDisplay[i].contentHeight/2+marker.contentHeight/2
			scrollView:insert(marker)
		end 
		
		x = x + boxSize + gap 
		
		if i%4 == 0 then 
			y = y + boxSize + gap 
			x = boxSize/2 
		end 
		
		levelsDisplay[i]:addEventListener("touch",selectLevel)
		
	end 

end 


function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase
    local parent = event.parent  --reference to the parent scene object

    if ( phase == "will" ) then
        -- Call the "resumeGame()" function in the parent scene
       
    end
end


scene:addEventListener( "create", scene )
scene:addEventListener( "hide", scene )
return scene