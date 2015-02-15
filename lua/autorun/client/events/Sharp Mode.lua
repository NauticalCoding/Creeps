//
/* 

	Sharp mode event
	
	Made by Nautical
*/

// Local vars

local event = {
	
	name = "Sharp mode",
	started = false,
	finished = false,
}

event.chatSayings = {

	"I see you.",
	"I'm coming.",
	"Wake up, and smell the ashes.",
	"Behind you.",
	"Hahahahaha!",
	"Fresh meat!",
	"Soon.",
	"I will consume you.",
}

event.sounds = {

	"ambient/atmosphere/tone_alley.wav",
	"ambient/atmosphere/tone_quiet.wav",
	"ambient/atmosphere/tunnel1.wav",
	"ambient/atmosphere/sewer_air1.wav",
	"creeps/Ambient16.wav",
	"creeps/Ambient17.wav",
	"creeps/Ambient19.wav",
}

// Local methods

function event.main()
	
	surface.PlaySound( table.Random( event.sounds ) )
	
	hook.Add( "RenderScreenspaceEffects","sharpasfuck",function()

		DrawSharpen( 2.5, 18 )
	end )
	
	hook.Add( "OnPlayerChat","hijackplayerchatlol",function( ply,strText )
	
		chat.AddText( Color( 0,0,0,255 ),"Gman: ",Color( 255,255,255,255 ),table.Random( event.chatSayings ) )
	
		return true
	end )
	
	timer.Simple( 15,function()
	
		blink()
	
		hook.Remove( "RenderScreenspaceEffects","sharpasfuck" )
		hook.Remove( "OnPlayerChat","hijackplayerchatlol" )
		
		RunConsoleCommand( "stopsound" )
		RunConsoleCommand( "-right" )

		event.finished = true
	end )
end

// Add event

addEvent( event )
