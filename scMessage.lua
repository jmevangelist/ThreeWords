local composer = require( "composer" )
local widget = require("widget")
local chartboost = require( "plugin.chartboost" )
local jsonUtils = require( "jsonUtils" )

local centerX = display.contentCenterX
local centerY = display.contentCenterY
local _W = display.contentWidth
local _H = display.contentHeight

local scene = composer.newScene()
local header = ""
local body = "" 
local messageType 
local okFunction

function scene:create( event )
	local sceneGroup = self.view 
	


	
	if event.params then 
		header = event.params.header 
		body = event.params.body 
		messageType = event.params.messageType 
		icon = event.params.icon
		okFunction = event.params.okFunction
		okButton = event.params.okButton
	end 
	
	if icon == nil then icon = "res/exclamation.png" end 
	
	local cover = display.newRect(sceneGroup,centerX,centerY,360,570)
	cover:setFillColor(unpack(colorPalette.dark))
	cover.alpha = 0.95
	
	local message = display.newGroup()
	message.anchorChildren = true 
	sceneGroup:insert(message)

	local function closeMessage(event)
		if event.phase == "ended" then 
			print("close")
			--transition.to(event.target,{xScale = 0.01, yScale = 0.01, time = 100, onComplete = function(obj) display.remove(obj) 
			--	obj = nil 
				composer.hideOverlay()
			--	end})
		end 
	end 


	local smallPane = display.newImageRect(message,"res/smallPanel.png",771*0.25,622*0.25)
	smallPane.x, smallPane.y = centerX, centerY
	local top = display.newGroup()
	top.anchorChildren = true 
	message:insert(top) 
	local rewardedVideo = display.newImageRect(top,icon,23,23)
	local notAvailable = display.newText(top,header,rewardedVideo.x + rewardedVideo.width/2 + 5,0,font,18)
	notAvailable.anchorX = 0 
	notAvailable:setFillColor(unpack(colorPalette.dark))
	top.anchorY = 0 
	top.x,top.y = centerX, smallPane.y - smallPane.contentHeight/2 + 20

	local pleaseTry = display.newText({
													parent = message,
													text = body,
													x = centerX,
													y = top.y + top.contentHeight + 5,
													width = 150,
													font = font,
													fontSize = 12,
													align = "center"})
	pleaseTry:setFillColor(unpack(colorPalette.dark))
	pleaseTry.anchorY = 0 
	
	
	local x = display.newImageRect(message,"res/cross-black.png",15,15)
	x.x, x.y = smallPane.x + smallPane.contentWidth/2 - 5, smallPane.y - smallPane.contentHeight/2 + 5

	x.anchorX = 1
	x.anchorY = 0 
	
	message.x, message.y = centerX, centerY 
	
	message:addEventListener("touch",closeMessage)
	
	local function yes(event)
		if event.phase == "ended" then 
			
			closeMessage(event)
			okFunction()
		end 
	end 
	
	if messageType == "question" then 
		if okButton then 
			local yes_button = widget.newButton(
				{
					id = "yes",
					width = 80,
					height = 30,
					x = centerX,
					y = smallPane.y + smallPane.contentHeight/2 - 30,
					defaultFile = okButton,
					overFile = okButton,
					onEvent = yes 
				}
			)
			sceneGroup:insert(yes_button)			
		else 
			local yes_button = widget.newButton(
				{
					id = yes,
					label = "YES",
					onEvent = yes,
					emboss = false,
					-- Properties for a rounded rectangle button
					shape = "roundedRect",
					width = 80,
					height = 30,
					fontSize = 20,
					font = font,
					cornerRadius =10,
					fillColor = { default={115/255,137/255,232/255,1}, over={1,0.1,0.7,0.4} },
					labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
					x = centerX,
					y = smallPane.y + smallPane.contentHeight/2 - 25 
				}
			)
			sceneGroup:insert(yes_button)
		end 
	end 
	
end 	

function scene:show(event)
	local sceneGroup = self.view
    local phase = event.phase
	
	
end 

function scene:hide( event )
    local message = self.view
    local phase = event.phase
	local parent = event.parent

	
end


scene:addEventListener( "create", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "show", scene )
return scene