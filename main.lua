-- version 1.0 

-- this is from scrange but we'll reprogram it because well... I got a new idea on the switching part 
-- instead of the words going up the screen when it's formed it will stay on place and a mark ( a check maybe or just make the letters pop out with a different color )
	-- will indicate that the word is "correct"
-- "correct" meaning that it is in the database 
-- but not entirely because it might not fit in the whole puzzle 

-- alright I think we did good today 
-- managed to do the main game thingy and wrote 10 levels too 
-- next up would be the leveling itself
-- dream about what layout would be nice or ui flow 
-- ***thinking of doing not just 3x3 puzzles and make the game evolve from 3x3 up to 6x6 -- similar to "flow" game 
-- ***hints can be in the form of a word reveal or letter(s) reveal 

-- version 1.01 

-- leveling done and added a visual cue so the player can see which letter will be swapped with 
-- ***had this crazy idea of doing a 3x3 puzzle wherein the words should not only form horizontally but also vertically 
-- tried doing some and actually came up with two. I think it's doable but it will take time to write all the puzzles 
-- so I'll just write this one down here instead and see if we'll have time to implement it
-- code wise won't take much, but doing the puzzles will take time. Unless I wrote a code that would automate it.. hmmn.. of course that's possible 
-- anyway.. I wanna wrap up this game as fast as possible so I'll focus on doing the whole shebang now and make it more presantable and whole 
-- and after that we'll see if we'd still want to add that crazy 3x3 

-- ***thinking of adding some trivia or dictionary meaning when a hard word is solved 

-- version 1.02 
-- I'm not sure if I should work tonight or just play or just watch that movie I downloaded weeks ago 
-- Tomorrow I'll have a bunch of important things to do so.. oh man.. 

-- version 1.03
-- Yay some progress! Managed to add sharing 
-- and levels screen too, also updated the algo in which the game looks for a level to unlock upon completing a level 
-- next: level pick feature and unlock via rewarded 
--	need to add visual cue so players will see the levels button when they are stuck 

-- version 1.04 
-- added pick level feature in levels screen 
-- updated and corrected algo for level unlocking 
--	*add a display on next level screen which level got unlocked 

-- version 1.05 
-- actually skipped some versions
-- but I guess we did well today 
-- ever had moments wherein you start questioning yourself why are you doing a task right in the middle of it? 
--	and you have this weird lost feeling, because you can't answer it? You don't know.. and you're afraid you'd loose motivation to finish what you've started
-- all because you forgot why you started it in the first place 
-- I had that feeling a few moments ago. I remembered a scene in memento. He was running away from a guy and because of his condition he forgot what he was doing right in the middle of it. 
--	"What am I doing?" he asked himself. "Am I chasing that guy?" and so he did.. and then he found out he wasn't chasing the guy but actually running from him. 
--	found notes on his car and deducted what he needed to do and went from there. I guess I'll try to do something similar. I'll just keep on doing this, even though I've forgotten why
-- the person that started it anyway might be that one genius person in me that surfaced for a while and planned on doing this. And I'm gonna trust her. 

-- to do: put sounds :) 
-- test admob fullscreen 


display.setStatusBar(display.HiddenStatusBar)
local jsonUtils = require("jsonUtils")
local file = require("fileFunctions")
local widget = require("widget")
local composer = require "composer" 
-- local ads = require("plugin.admob")

-- Global variables 
font = "Century Gothic"
gamePlayCounter = 0
adsFrequency = 2 

colorPalette = { 
			background = {32/255,32/255,32/255,1},
			primary ={41/255,128/255,185/255,1},
			dark ={44/255,62/255,80/255,1},
			light ={236/255,240/255,241/255,1},
			complement ={231/255,76/255,60/255,1},
			}
			
-- local memUsageDisplay = display.newText(0,display.contentWidth/2,display.contentHeight-50,font,20)
-- local texUsedDisplay = display.newText(0,display.contentWidth/2,display.contentHeight-20,font,20)
-- local function displayMemUsage()

-- 	local memUsage = (collectgarbage("count")) / 1000 
-- 	local texUsed = system.getInfo("textureMemoryUsed") / 100000
	
-- 	memUsageDisplay.text = "memory: "..string.format("%.03f",memUsage)
-- 	texUsedDisplay.text = "texture: "..texUsed
	
-- end 
-- Runtime:addEventListener( "enterFrame", displayMemUsage )

--setUp Variables
local vungleAppID = "56df21ec0db481ec3000000c"
local admob_bannerAppID = "ca-app-pub-2632221781859165/6739772995"
local admob_interstitial = "ca-app-pub-2632221781859165/8216506193"


-------------------------------
-- Copy and init Game Data 
-------------------------------
print("Loading gameData")
file.copyFile( "gameData.json", nil, "gameData.json", system.DocumentsDirectory, false )
gameData = jsonUtils.init({jsonFileName = "gameData.json", path = system.DocumentsDirectory})
gameDataTable = gameData:load()


-------------------------------
--	Ads
-------------------------------

function setUpVungle()

	function vungleListener(event)
		
		print("VungleLister", "type:", event.type, "Error:", event.isError)
	
		if ( event.type == "adStart" and event.isError ) then
		-- Ad has not finished caching and will not play
		end
		
		if ( event.type == "adStart" and not event.isError ) then
		-- Ad will play
		end
		
		if ( event.type == "cachedAdAvailable" ) then
		-- Ad has finished caching and is ready to play
		end
		
		if ( event.type == "adView" ) then
		-- An ad has completed
			if event.isCompletedView then 
				--the ad was watched 
			end 
		end
		
		if ( event.type == "adEnd" ) then
		-- The ad experience has been closed- this
		-- is a good place to resume your app
			--reward the player here 
		--[[	local currScene = composer.getSceneName( "current" )
			if currScene == "scMenu" or currScene == "scGameOver" then
				--free coins reward 
				print("free coins reward")
				composer.showOverlay("scMessage",{isModal = true,params = {header = "Yay!!", body =  gameVariables.creditRewards .." credits added"}})
				gameDataTable.credits = gameDataTable.credits + gameVariables.creditRewards 
				gameData:save(gameDataTable)
				
				local sceneObject = composer.getScene( currScene )
				sceneObject.updateCreditsDisplay()
				--native.showAlert( "Yay!!", gameVariables.creditRewards .." credits added", { "OK" } )
				
			else
				--continue game reward 
				print("continue game reward")
				--composer.hideOverlay()
			end
			ads:setCurrentProvider( "admob" ) --]]
			local currScene = composer.getSceneName( "current" )
			if currScene == "scLevels" then 
				local sceneObject = composer.getScene( currScene )
				sceneObject.unlockLevel()
			end 
		end

	end 

	print("Setting up vungle.")
	-- ads.init( "vungle", vungleAppID, vungleListener )
end 

function setUpAdmob()
	local adProvider = "admob"
	local appID = admob_bannerAppID

	function adListener( event )

		local msg = event.response
		print("Message from ads lib: ",msg)
		
		if (event.isError) then
			print("Error, no ad received", msg)
			msg = "Error, no ad received" .. msg
			
			
		else
			print("Got one ad :) ")
			
		end
		

		
	end

	-- ads.init(adProvider,appID,adListener)
end 

-- setUpVungle()
-- setUpAdmob()
 
-------------------------------
-- Load Game Screen 
-------------------------------
composer.gotoScene("scGameScreen")