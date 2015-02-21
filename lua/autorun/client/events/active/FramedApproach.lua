//
/* 

	Framed Approach event
	
	Made by Nautical
*/

// Event vars

local event = {
	
	name = "Framed Approach",
	type = "active",
	started = false,
	finished = false,
}

event.sounds = {

	ambience = {
	
		"creeps/Ambient5.wav",
		"creeps/Ambient17.wav",
		"ambient/atmosphere/cave_hit6.wav",
	},

	monsterMove = "ambient/machines/thumper_hit.wav",
	
	scare = {
	
		"ambient/voices/squeal1.wav",
		"creeps/Horror3.wav",
		"creeps/Horror4.wav",
		"creeps/Horror7.wav",
		"creeps/Horror10.wav",
		"creeps/Horror11.wav",
		"creeps/Horror15.wav",
	},
}

// Event methods

function event.placemonster( monster,distance,ignoreLOS )
	
	local eyeAngles = quickAngles() 
	
	local pos = LocalPlayer():GetShootPos() + eyeAngles:Forward() * distance
	
	local collisionTrace = quickTrace( LocalPlayer():GetShootPos(),pos,{ LocalPlayer() } )
	
	if ( ignoreLOS || ( !collisionTrace.Hit && eyesClosed ) ) then
		
		local surfaceTrace = quickTrace( pos + Vector( 0,0,80 ),pos - Vector( 0,0,9999 ) )
		
		monster:SetPos( surfaceTrace.HitPos )
		
		local angleToMe = ( ( LocalPlayer():GetPos() + LocalPlayer():GetVelocity() / 2 )  - monster:GetPos() ):Angle()
		angleToMe.p = 0
		
		monster:SetAngles( angleToMe )
		
		surface.PlaySound( event.sounds.monsterMove )
		
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
	
	timer.Create( "reposition monster",.1,0,function()
	
		local canMovemonster = event.placemonster( monster,distance - 500,false )
	
		if ( canMovemonster ) then
		
			distance = distance - 250
		end
	
		if ( LocalPlayer():GetPos():Distance(monster:GetPos()) < 200 ) then
		
			event.placemonster( monster,50,true )
			
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
