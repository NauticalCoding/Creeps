//
/* 

	All Gman event
	
	Made by Nautical
*/

// Event vars

local event = {
	
	name = "All Gman",
	started = false,
	finished = false,
}

event.oldModels = {}

event.sounds = {

	"ambient/atmosphere/ambience5.wav",
	"ambient/atmosphere/ambience6.wav",
	"ambient/atmosphere/hole_hit1.wav",
	"ambient/atmosphere/hole_amb3.wav",
	"ambient/atmosphere/cave_hit3.wav",
	"ambient/atmosphere/cave_hit4.wav",
	"creeps/Ambient5.wav",
	"creeps/Ambient6.wav",
	"creeps/Ambient11.wav",
	"creeps/Ambient13.wav",
}

// Event methods

function event.switchModels( bool ) // true = change all player models to gman ( lol ), false = change them back

	for k,v in pairs( player.GetAll() ) do
		
		if ( bool ) then
			
			event.oldModels[ v:SteamID() ] = v:GetModel()
			
			v:SetModel( "models/player/gman_high.mdl" )
			v:SetMaterial( "models/debug/debugwhite" )
			v:SetColor( Color( 0,0,0,255 ) )
			
		else
		
			if ( v:GetModel() != "models/player/gman_high.mdl" && v:GetModel() != "event.oldModels[ v:SteamID() ]" ) then
				
				event.oldModels[ v:SteamID() ] = v:GetModel()
			end
		
			v:SetModel( event.oldModels[ v:SteamID() ] )
			v:SetMaterial( "" )
			v:SetColor( Color( 255,255,255,255 ) )
		end
		
	end
end

function event.main()

	surface.PlaySound( table.Random( event.sounds ) )
	event.switchModels( true )
	
	timer.Simple( 10,function()
			
		blink()
		
		RunConsoleCommand( "stopsound" )
		event.switchModels( false )
		event.finished = true
	end )
end

// Add event

addEvent( event )