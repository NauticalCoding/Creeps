//
/*

	Creeps main.lua
	
	Forces a client to endure popup scares, hallucinations and other distortions of game world.
	
	All this code is clientside
	
	Made by Nautical
*/

// Local vars

local config = { // default configuration, this can be overridden by the server via the net library
		
	allowEvents					= 0, // Enables / disables events
	timerDelay 					= 10, // Delay in between blinks and event attempts
	maximumBrightness			= 60, // Maximum environment brightness in which an event can take place
	debugMode					= 1, // enables debug printing
	eventChance					= 25, // 0% - 100% chance of event occuring
}

local events = {} // each table in here will be an "event", events are selected randomly
local selectedEvent; // currently selected event ( events[ selectedEvent ] )
local lastEvent = 0 // most recently run event, used to prevent an event from running twice in a row

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

canSee = true

// Global methods

function debugPrint( msg )

	if ( config.debugMode == 0 ) then return end

	MsgC( Color( 255,0,255,255 ),"[ Creeps ] " .. msg .. "\n" )
end

function addEvent( eventTable )

	events[ #events + 1 ] = eventTable
	
	debugPrint( "added event " .. eventTable.name )
end	

function inFOV( pos ) 

	local ang = ( pos - LocalPlayer():GetShootPos() ):Angle() - LocalPlayer():EyeAngles()
	ang.p = math.abs( math.NormalizeAngle( ang.p ) )
	ang.y = math.abs( math.NormalizeAngle( ang.y ) )
	
	if ( ang.y > 75 || ang.p > 40 || !canSee ) then
		
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

function blink( delay )

	if ( !canSee ) then return end

	delay = delay || .25

	hook.Add( "HUDPaint","CREEPS_blink",function()
	
		surface.SetDrawColor( Color( 0,0,0,255 ) )
		surface.DrawRect( 0,0,ScrW(),ScrH() )
		
		canSee = false
	end )
	
	timer.Simple( delay,function()
	
		canSee = true
		hook.Remove( "HUDPaint","CREEPS_blink" )
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

// Local methods

local function includeEventScripts()

	local files = file.Find( "lua/autorun/client/events/*.lua","GAME" )
	
	for k,v in pairs( files ) do
	
		include( "events/"..v )
	end
	
	debugPrint( "Loaded event scripts" )
end

includeEventScripts()

local function approxBrightness()

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
	
	debugPrint( "calculating brightness " .. approx )
	
	return approx
end

local function runEvents() // selects an event, then based on chance and canSee, will attempt to run the selected event

	if ( config.allowEvents == 0 ) then return end // allows toggling events
	
	blink( .15 ) // blink for .15 seconds
	
	if ( selectedEvent == nil ) then // choose a random event
		
		
		selectedEvent = lastEvent
		//selectedEvent = 2
		
		while ( selectedEvent == lastEvent ) do
		
			selectedEvent = math.random( 1,#events )
			
			debugPrint( "selecting random event!" )
		end
	end
	
	if ( !events[ selectedEvent ].started ) then
	
		local chanceToRun = math.random( 1,100 )
	
		if ( chanceToRun <= config.eventChance && approxBrightness() < config.maximumBrightness ) then
	
			events[ selectedEvent ].main()
			events[ selectedEvent ].started = true
			
			debugPrint( "starting event: " .. events[ selectedEvent ].name )
		end
	end
	
	if ( events[ selectedEvent ].finished ) then
			
		events[ selectedEvent ].started = false // reset the started/finished variables
		events[ selectedEvent ].finished = false
			
		lastEvent = selectedEvent
			
		debugPrint( "finished event: " .. events[ selectedEvent ].name )
			
		selectedEvent = nil // set selectedEvent back to nil, so the first if statement will be called next time
	end
end

timer.Create( "Mother Event Timer",config.timerDelay,0,runEvents )