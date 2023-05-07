local composer = require( "composer" )
local widget = require("widget")

local scene = composer.newScene()

local centerX = display.contentCenterX
local centerY = display.contentCenterY
local _W = display.contentWidth
local _H = display.contentHeight

function scene:create( event )
	local sceneGroup = self.view
	
	local background = display.newRect(sceneGroup,centerX,centerY,_W,_H)
	background:setFillColor(colorPalette.dark)
	background.alpha = 0.9 
	
	local panel = display.newImageRect(sceneGroup,"res/largePanel.png",956*0.28,1206*0.28)
	panel.x,panel.y = centerX,centerY 
	
	local howToPlayText = "Drag and switch the letters to spell out three words"
	local specialThanks = "Special Thanks to:\nSFX: Andy Rhode\nIcons: Kenney Vleugels\nColor Theme: Flat UI by Yorick\nBeta Tester: Kepweng"
	local credits = "Three Words by Joan Evangelista\nCopyright © 2016"
	
	local button_sound, button_soundOff
	local function handleButtonEvent(event)
		if event.phase == "ended" then 
		
			if event.target.id == "rate" then 
				local options =
					{
					   supportedAndroidStores = { "google", "amazon" }
					}
					native.showPopup( "appStore", options )
			elseif event.target.id == "sound" then 
				if gameDataTable.audio_on then 
					gameDataTable.audio_on = false
					audio.stop()
					transition.dissolve( button_sound, button_soundOff, 100,0 )
				else
					gameDataTable.audio_on = true 
					transition.dissolve( button_soundOff, button_sound, 100, 0 )
				end 
				gameData:save(gameDataTable)
			elseif event.target.id == "close" then 
				 
				composer.hideOverlay()
			end 
		end 
	end 
	
	local back_button = widget.newButton
	{
		id = "close",
		width = 64*0.25,
		height = 64*0.25,
		defaultFile = "res/cross-black.png",
		overFile = "res/cross-black.png",
		x = panel.x + panel.contentWidth/2 - 20,
		y = panel.y - panel.contentHeight/2 + 20,
		onEvent = handleButtonEvent		
	}
	sceneGroup:insert(back_button)
	
	local howToPlayDisplayHeader = display.newText(sceneGroup,"How To Play",centerX,back_button.y+back_button.contentWidth/2 + 5,font,30)
	howToPlayDisplayHeader:setFillColor(unpack(colorPalette.dark))
	howToPlayDisplayHeader.anchorY = 0 
	
	local howToPlayDisplay = display.newText({parent = sceneGroup,
		text = howToPlayText,
		align = "center",
		width = 200,
		font = font,
		fontSize = 15,
		x = centerX,
		y = howToPlayDisplayHeader.y + howToPlayDisplayHeader.contentHeight + 10 
	})
	howToPlayDisplay.anchorY = 0 
	howToPlayDisplay:setFillColor(unpack(colorPalette.primary))
	
	
	
	local buttons = display.newGroup()
	buttons.anchorChildren = true 
	sceneGroup:insert(buttons) 
	
	button_sound = widget.newButton
	{
		id = "sound",
		width = 48*0.7,
		height = 48*0.7,
		defaultFile = "res/soundOn.png",
		overFile = "res/soundOn.png",
		label = "Mute",
		labelXOffset = 30,
		font = font,
		fontSize = 15,
		labelAlign = "left",
		labelColor = { default={ unpack(colorPalette.background)}, over={ 1,1,1,1 } },
		x = 0,
		y = 48*0.7*0.5,
		onEvent = handleButtonEvent
	}
	button_sound.anchorX = 0 
	buttons:insert(button_sound)	
	
	button_soundOff = widget.newButton
	{
		id = "sound",
		width = 43*0.7,
		height = 43*0.7,
		defaultFile = "res/soundOff.png",
		overFile = "res/soundOff.png",
		label = "Mute",
		labelXOffset = 30,
		font = font,
		fontSize = 15,
		labelAlign = "left",
		labelColor = { default={  unpack(colorPalette.background) }, over={ 1,1,1,1 } },
		x = 0,
		y = button_sound.y,
		onEvent = handleButtonEvent
	}
	buttons:insert(button_soundOff)	
	button_soundOff.anchorX = 0 
	
	if gameDataTable.audio_on then 
		button_soundOff.alpha = 0 
	else 
		button_sound.alpha = 0 
	end 
 
	local button_rate = widget.newButton
	{
		id = "rate",
		width = 43*0.7,
		height = 43*0.7,
		defaultFile = "res/rate.png",
		overFile = "res/rate.png",
		x = button_soundOff.x + button_soundOff.contentWidth + 20,
		y = button_soundOff.y,
		onEvent = handleButtonEvent,
		label = "Rate Us",
		labelXOffset = 30,
		labelAlign = "left",
		font = font, 
		fontSize = 15,
		emboss = false,
		labelColor ={ default={  unpack(colorPalette.background) }, over={ 1,1,1,1 } },
	}
	buttons:insert(button_rate) 
	button_rate.anchorX = 0 
	
	buttons.anchorY = 0 
	buttons.y,buttons.x = howToPlayDisplay.y + howToPlayDisplay.contentHeight +15, centerX
	
	local specialThanksDisplay = display.newText({
		parent = sceneGroup,
		text = specialThanks,
		align = "center",
		width = 220,
		font = font,
		fontSize = 13,
		x = centerX,
		y = buttons.y + buttons.contentHeight + 15 
	})
	specialThanksDisplay.anchorY = 0 
	specialThanksDisplay:setFillColor(unpack(colorPalette.primary))
	
	local like = widget.newButton 		
	{	id = "facebook",
		width = 100*0.25,
		height = 86*0.25,
		defaultFile = "res/like.png",
		overFile = "res/like.png",
		x = panel.x - panel.contentWidth/2 + 30,
		y = panel.y + panel.contentHeight/2 - 30,
		onEvent = handleButtonEvent		
	}
	sceneGroup:insert(like)
	
	local creditsDisplay = display.newText({
		parent = sceneGroup,
		text = credits,
		align = "left",
		width = 220,
		font = font,
		fontSize = 12,
		x = like.x + like.contentWidth/2 + 10,
		y = like.y
	})
	creditsDisplay:setFillColor(unpack(colorPalette.dark))
	creditsDisplay.anchorX = 0 
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