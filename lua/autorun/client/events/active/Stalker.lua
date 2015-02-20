//
/* 

	Stalker event
	
	Made by Nautical
*/

// Event vars

local event = {
	
	name = "Stalker",
	type = "active",
	started = false,
	finished = false,
}

event.sounds = {
	
	behindYou = {
	
		"vo/k_lab/eli_behindyou.wav",
		"vo/npc/female01/behindyou01.wav",
		"vo/npc/female01/behindyou02.wav",
		"vo/npc/male01/behindyou01.wav",
		"vo/npc/male01/behindyou02.wav",
	},
	
	scare = {
		
		"creeps/Horror10.wav",
		"creeps/Horror15.wav",
		"creeps/Horror11.wav",
	},
}

// Event methods

function event.main()

	surface.PlaySound( table.Random( event.sounds.behindYou ) )
	
	timer.Create( "randSoundTimer",10,0,function()
	
		surface.PlaySound( table.Random( event.sounds.behindYou ) )
	end )
	
	local monster = quickMonster()
	monster:SetMaterial( "models/debug/debugwhite" )
	monster:SetColor( Color( 0,0,0,255 ) )
	
	local eyeAngles = quickAngles() 
	
	hook.Add( "Think","moveClientModel",function()
	
		if ( monster == nil ) then return end
		
		local pos = LocalPlayer():GetPos() - eyeAngles:Forward() * 50
		
		local angleToMe = ( LocalPlayer():GetPos() - pos ):Angle()
		angleToMe.p = 0
		
		if ( !inFOV( pos + Vector( 0,0,80 ) ) && !inFOV( pos ) ) then
		
			monster:SetPos( pos )
			monster:SetAngles( angleToMe )
		else
		
			// Force look at monster's face
			
			local angToFace = ( ( monster:GetPos() + Vector( 0,0,67 ) ) - LocalPlayer():GetShootPos() ):Angle()
			LocalPlayer():SetEyeAngles( angToFace )
			
			hook.Remove( "Think","moveClientModel" )
			timer.Destroy( "randSoundTimer" )
			RunConsoleCommand( "stopsound" )
			
			timer.Simple( .15,function() 

				surface.PlaySound( table.Random( event.sounds.scare ) )
				blink()
				monster:Remove()
				event.finished = true
			end )
		end
	end )
end

// Add event

addEvent( event )