//
/* 

	Glide Follow event
	
	Made by Nautical
*/

// Event vars

local event = {
	
	name = "Glide Follow",
	started = false,
	finished = false,
}

event.sounds = {

	ambience = {
	
		"player/heartbeat1.wav",
	},
	
	kill = {
	
		"creeps/NeckSnap1.wav",
		"creeps/NeckSnap3.wav",
	},

	scare = {

		"creeps/Horror3.wav",
		"creeps/Horror4.wav",
		"creeps/Horror7.wav",
		"creeps/Horror10.wav",
		"creeps/Horror15.wav",
	}

}

// Local methods

function event.destroyMonster( monster )

	blink()
	monster:Remove()
	event.finished = true
	
	timer.Simple( 4,function()
	
		RunConsoleCommand( "stopsound" )
	end )
end

function event.main()

	surface.PlaySound( table.Random( event.sounds.ambience ) )
	
	local monster = quickMonster()
	
	local eyeAngles = quickAngles() 
	
	monster:SetPos( LocalPlayer():GetPos() + eyeAngles:Forward() * 500 )
	
	hook.Add( "Think","followplayer",function()

		if ( LocalPlayer():GetPos():Distance( monster:GetPos() ) < 100 ) then
		
			hook.Remove( "Think","followplayer" )
		
			eyeAngles = quickAngles()
			
			monster:SetPos( LocalPlayer():GetPos() + eyeAngles:Forward() * 20 )
			
			local chanceOfDeath = math.random( 1,2 )
			
			if ( chanceOfDeath == 1 ) then
				
				surface.PlaySound( table.Random( event.sounds.kill ) )
				fakeDeath()
				
			else
			
				surface.PlaySound( table.Random( event.sounds.scare ) )
			end
			
			timer.Simple( .20,function()
			
				event.destroyMonster( monster )
			end )
		end
	
		local angToMe = ( LocalPlayer():GetPos() - monster:GetPos() ):Angle()
		
		monster:SetPos( monster:GetPos() + angToMe:Forward() * 6 )
		monster:SetAngles( Angle( 0,angToMe.y,0 ) )
	end )
	
	timer.Simple( 20,function()
	
		if ( monster:IsValid() ) then
		
			hook.Remove( "Think","followplayer" )
		
			event.destroyMonster( monster )
		end
	end )
end

// Add event

addEvent( event )
