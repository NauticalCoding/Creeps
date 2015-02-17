//
/* 

	Popup scare event
	
	Made by Nautical
*/

// Event vars

local event = {
	
	name = "Popup scare",
	started = false,
	finished = false,
}

event.sounds = {

	"creeps/Horror3.wav",
	"creeps/Horror4.wav",
	"creeps/Horror7.wav",
	"creeps/Horror10.wav",
	"creeps/Horror15.wav",
}

// Event methods

function event.main()

	local monster = quickMonster()
	
	local eyeAngles = quickAngles() 

	local infrontOfPlayer = LocalPlayer():GetPos() + ( LocalPlayer():GetVelocity() / 2 ) + eyeAngles:Forward() * 50
	local collisionTrace = quickTrace( LocalPlayer():GetShootPos(),infrontOfPlayer,{ LocalPlayer() } ) // check if there is a wall infront of us
	
	collisionTrace.HitPos = collisionTrace.HitPos - eyeAngles:Forward() * 10 // nudge the model towards us 10 units
	
	local surfaceTrace = quickTrace( collisionTrace.HitPos + Vector( 0,0,80 ),collisionTrace.HitPos - Vector( 0,0,9999 ) ) // find the new surface elevation by tracing from top to bottom

	infrontOfPlayer = Vector( collisionTrace.HitPos.x,collisionTrace.HitPos.y,surfaceTrace.HitPos.z ) // use the new x,y,z values we found
	
	monster:SetPos( infrontOfPlayer )
	
	local angleToPlayer = ( LocalPlayer():GetPos() - monster:GetPos() ):Angle()
	angleToPlayer.p = 0
	angleToPlayer.y = math.NormalizeAngle( angleToPlayer.y )
	angleToPlayer.r = 0
	
	monster:SetAngles( angleToPlayer )
	
	timer.Simple( .25,function()
	
		surface.PlaySound( table.Random( event.sounds ) )
	end )
	
	timer.Simple( .5,function()
	
		blink()
	
		monster:Remove()
		
		event.finished = true
	end )
end

// Add event

addEvent( event )

