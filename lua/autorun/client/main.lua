//
/*

	Creeps main.lua
	
	Forces a client to endure popup scares, hallucinations and other distortions of game world.
	
	All this code is clientside
	
	Made by Nautical
*/

// Local vars

local render = table.Copy( render )

local config = { // default configuration, this can be overridden by the server via the net library
		
	allowEvents					= 0, // Enables / disables events
	timerDelay 					= 10, // Delay in between blinks and event attempts
	prefBrightness				= 90, // Preferred environment brightness in which an event can take place
	debugMode					= 1, // enables debug printing
	activeEventChance			= 25, // 0% - 100% chance of event occuring
	passiveEventChance			= 75, // 0% - 100%
	blinkSpeed 					= 35, // how fast the eyes blink, larger number = slower blink and vice versa
}

local events = { // each table in here will be an "event", events are selected randomly
	
	active = {},
	passive = {},
}

local selectedActiveEvent; // currently selected event ( events[ selectedActiveEvent ] )
local lastActiveEvent = 0 // most recently run event, used to prevent an event from running twice in a row
local selectedPassiveEvent;
local lastPassiveEvent = 0

local monsterModels = {

	"models/gman_high.mdl",
	"models/stalker.mdl",
}

// Net receive

net.Receive( "CREEPS_CONFIG_BROADCAST",function(len)

	config = net.ReadTable()
end )

net.Receive("CREEPS_PRIVATE_MESSAGE",function(len)

	chat.AddText(Color(255,0,0,255),"[CREEPS] ",Color(255,255,255,255),net.ReadString())
end )

// Global vars

canBlink = true
eyesClosed = false

// Global methods

function debugPrint( msg )

	if ( config.debugMode == 0 ) then return end

	MsgC( Color( 255,150,0,255 ),"[ Creeps ] " .. msg .. "\n" )
end

function addEvent( eventTable )
	
	if (eventTable == nil) then return end
	if (eventTable.type == nil) then return end
	
	if (string.lower(eventTable.type) == "active") then
	
		events.active[ table.Count(events.active) + 1 ] = eventTable
	elseif(string.lower(eventTable.type) == "passive") then
	
		events.passive[ table.Count(events.passive) + 1 ] = eventTable
	end
	
	debugPrint( "	->Successfully added event " .. eventTable.name )
end	

function inFOV( pos ) 

	local ang = ( pos - LocalPlayer():GetShootPos() ):Angle() - LocalPlayer():EyeAngles()
	ang.p = math.abs( math.NormalizeAngle( ang.p ) )
	ang.y = math.abs( math.NormalizeAngle( ang.y ) )
	
	if ( ang.y > 75 || ang.p > 40 || eyesClosed ) then
		
		return false
		
	else
	
		return true
	end

end

function quickTrace( pos1,pos2,filter )

	filter = filter || {}
	
	local tr = {}
	tr.start = pos1
	tr.endpos = pos2
	tr.mask = MASK_SOLID
	tr.filter = filter
	
	return util.TraceLine( tr )
end

function blink(delay)

	if ( !canBlink ) then return end
	
	delay = delay || 0
	canBlink = false
	
	local eyelidW = ScrW()
	local eyelidH = ScrH()
	
	local desiredY = ScrH() / 2
		
	local eyelidUpper = -eyelidH // this is the y coordinate of the upper eyelid
	local eyelidLower = ScrH()

	hook.Add( "HUDPaint","CREEPS_blink",function()
	
		// move eyelids
		
		if (!eyesClosed) then
		
			local yDiff = eyelidLower - desiredY
		
			if ( ( yDiff <= 0 ) && delay != -1 ) then
				
				if (delay > 0) then
				
					timer.Simple(delay,function()
					
						eyesClosed = true
					end)
				else
				
					eyesClosed = true
				end
				
				delay = -1
			
			elseif ( eyelidUpper < desiredY && eyelidLower > desiredY) then
				eyelidUpper = eyelidUpper + (eyelidH / config.blinkSpeed) // x calls to this method then the eyelids are fully closed
				eyelidLower = eyelidLower - (eyelidH / config.blinkSpeed)
			end
			
		else
		
		
			if (eyelidUpper == -eyelidH || eyelidLower == ScrH()) then
			
				eyesClosed = false
				canBlink = true
				hook.Remove( "HUDPaint","CREEPS_blink" )
			
			elseif ( eyelidUpper > -eyelidH || eyelidLower > ScrH() ) then
				
				eyelidUpper = eyelidUpper - (eyelidH / config.blinkSpeed) // x calls to this method then the eyelids are fully opened
				eyelidLower = eyelidLower + (eyelidH / config.blinkSpeed)
			end
		end
	
	
		surface.SetDrawColor( Color( 0,0,0,255 ) )
		surface.DrawRect( 0,eyelidUpper,eyelidW,eyelidH )
		surface.DrawRect( 0,eyelidLower,eyelidW,eyelidH)
	end )
	
	debugPrint( "blinking" )
end

function createClientModel( model )

	local clientModelObject = ClientsideModel( model,RENDERGROUP_BOTH )
	clientModelObject:SetPos( Vector( 0,0,-9999 ) )
	
	debugPrint( "created client model: " .. model )
	
	return clientModelObject
end

function quickAngles()

	local eyeAngles = LocalPlayer():EyeAngles()
	eyeAngles.p = 0
	eyeAngles.y = math.NormalizeAngle( eyeAngles.y )
	eyeAngles.r = 0
	
	return eyeAngles
end

function quickMonster()

	return createClientModel( table.Random( monsterModels ) )
end

function fakeDeath()

	blink( 6.5 )
	surface.PlaySound( "creeps/player_death.wav" )
end

function approxBrightness()

	render.CapturePixels()
	
	local totalPixels = 0
	local accumulativeColor = Color( 0,0,0,255 )
	local avgColor = Color( 0,0,0,255 )
	
	for x = 1,ScrW() do
		
		if ( x % 10 > 0 ) then continue end
	
		for y = 1,ScrH() do
		
			if ( y % 10 > 0 ) then continue end
			
			totalPixels = totalPixels + 1
		
			local r,g,b = render.ReadPixel( x,y )
			
			accumulativeColor.r = accumulativeColor.r + r
			accumulativeColor.g = accumulativeColor.g + g
			accumulativeColor.b = accumulativeColor.b + b

			if ( x == ScrW() && y == ScrH() ) then
				
				avgColor.r = accumulativeColor.r / totalPixels
				avgColor.g = accumulativeColor.g / totalPixels
				avgColor.b = accumulativeColor.b / totalPixels
			end
		end
	end
	
	local approx = ( avgColor.r + avgColor.g + avgColor.b ) / 3
	
	debugPrint( "Approximate brightness: " .. approx )
	
	return approx
end

// Local methods

local function includeScripts(subDir)

	local files = file.Find( "autorun/client/events/" .. subDir .. "/*.lua","LUA" )
	
	for k,v in pairs( files ) do
	
		debugPrint("Attempting to include script: events/" .. subDir .. "/"..v)
		include( "events/" .. subDir .. "/"..v )
	end
end

includeScripts("passive")
includeScripts("active")

/* Active event shit */

local function runActiveEvents() // selects an event, then based on chance and canBlink, will attempt to run the selected event

	if ( config.allowEvents == 0 ) then return end // allows toggling events
	
	if ( selectedActiveEvent == nil ) then // choose a random event
		
		//selectedActiveEvent = 9
		
		selectedActiveEvent = lastActiveEvent
		
		while ( selectedActiveEvent == lastActiveEvent ) do
		
			selectedActiveEvent = math.random( 1,table.Count(events.active) )
			
			debugPrint( "Selecting event " .. events.active[ selectedActiveEvent ].name )
		end
	end
	
	if ( !events.active[ selectedActiveEvent ].started ) then
	
		local chance = math.random(1,100)
		local chanceMultiplier = ( approxBrightness() / config.prefBrightness )
	
		if ( chance * chanceMultiplier <= config.activeEventChance ) then
	
			events.active[ selectedActiveEvent ].main()
			events.active[ selectedActiveEvent ].started = true
			
			debugPrint( "starting event: " .. events.active[ selectedActiveEvent ].name )
		end
	end
	
	if ( events.active[ selectedActiveEvent ].finished ) then
			
		events.active[ selectedActiveEvent ].started = false // reset the started/finished variables
		events.active[ selectedActiveEvent ].finished = false
			
		lastActiveEvent = selectedActiveEvent
			
		debugPrint( "Finished event: " .. events.active[ selectedActiveEvent ].name )
			
		selectedActiveEvent = nil // set selectedActiveEvent back to nil, so the first if statement will be called next time
	end
	
	blink()
end

timer.Create( "CREEPS_activeEventTimer",config.timerDelay,0,runActiveEvents )

/* Passive event shit */

local function runPassiveEvents()

	if ( config.allowEvents == 0 ) then return end // allows toggling events

	if ( selectedPassiveEvent == nil ) then // choose a random event
		
		//selectedPassiveEvent = 9
		
		selectedPassiveEvent = lastPassiveEvent
		
		while ( selectedPassiveEvent == lastPassiveEvent ) do
		
			selectedPassiveEvent = math.random( 1,table.Count(events.passive) )
			
			debugPrint( "Selecting event " .. events.passive[ selectedPassiveEvent ].name )
		end
	end
	
	if ( !events.passive[ selectedPassiveEvent ].started ) then
	
		local chanceToRun = math.random( 1,100 )
	
		if ( chanceToRun <= config.passiveEventChance ) then
	
			events.passive[ selectedPassiveEvent ].main()
			events.passive[ selectedPassiveEvent ].started = true
			
			debugPrint( "starting event: " .. events.passive[ selectedPassiveEvent ].name )
		end
	end
	
	if ( events.passive[ selectedPassiveEvent ].finished ) then
			
		events.passive[ selectedPassiveEvent ].started = false // reset the started/finished variables
		events.passive[ selectedPassiveEvent ].finished = false
			
		lastPassiveEvent = selectedPassiveEvent
			
		debugPrint( "Finished event: " .. events.passive[ selectedPassiveEvent ].name )
			
		selectedPassiveEvent = nil // set selectedPassiveEvent back to nil, so the first if statement will be called next time
	end
end

timer.Create("CREEPS_passiveEventTimer",config.timerDelay / 2,0,runPassiveEvents)
