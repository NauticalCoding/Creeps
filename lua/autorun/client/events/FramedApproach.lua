//
/* 

	Framed Approach event
	
	Made by Nautical
*/

// Local vars

local event = {
	
	name = "Framed Approach",
	started = false,
	finished = false,
}

event.sounds = {

	ambience = {
	
		"ambient/atmosphere/cave_hit4.wav",
		"ambient/atmosphere/cave_hit5.wav",
		"ambient/atmosphere/cave_hit6.wav",
	},

	monsterMove = "ambient/machines/thumper_hit.wav",
	
	scare = {
	
		"ambient/voices/squeal1.wav",
		"creeps/Horror3.wav",
		"creeps/Horror4.wav",
		"creeps/Horror7.wav",
		"creeps/Horror10.wav",
		"creeps/Horror15.wav",
		"ambient/rottenburg/tunneldoor_closed_loud.wav",
		"ambient/rottenburg/tunneldoor_closed_quiet.wav",
	},
}

// Local methods

function event.placemonster( monster,distance )
	
	local eyeAngles = quickAngles() 
	
	local pos = LocalPlayer():GetPos() + ( LocalPlayer():GetVelocity() / 2 ) + eyeAngles:Forward() * distance
	
	local collisionTrace = quickTrace( LocalPlayer():GetShootPos() + Vector( 0,0,40 ),pos + Vector( 0,0,40 ),{ LocalPlayer() } )
	
	if ( !collisionTrace.Hit ) then
		
		local surfaceTrace = quickTrace( pos + Vector( 0,0,80 ),pos - Vector( 0,0,9999 ) )
		
		monster:SetPos( surfaceTrace.HitPos )
		
		local angleToMe = ( ( LocalPlayer():GetPos() + LocalPlayer():GetVelocity() / 2 )  - monster:GetPos() ):Angle()
		angleToMe.p = 0
		
		monster:SetAngles( angleToMe )
		
		surface.PlaySound( event.sounds.monsterMove )
		blink()
		
		return true
		
	else
	
		return false
	end
end

function event.main()
	
	local monster = quickMonster()
	monster:SetMaterial( "models/debug/debugwhite" )
	monster:SetColor( Color( 0,0,0,255 ) )
	
	local distance = 1530
	
	timer.Create( "reposition monster",.4,0,function()
	
		local canMovemonster = event.placemonster( monster,distance - 500 )
	
		if ( canMovemonster ) then
		
			distance = distance - 500
		end
	
		if ( distance == 30 ) then
		
			blink()
			
			timer.Destroy( "reposition monster" )
			surface.PlaySound( table.Random( event.sounds.scare ) )
			
			timer.Simple( .5,function()
				
				blink()
				monster:Remove()
				event.finished = true
			end )
		end
	end )
end

// Add event

addEvent( event )
