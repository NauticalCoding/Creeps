//
/* 

	Boom Barrel event
	
	Made by Nautical
*/

// Event vars

local event = {
	
	name = "Boom Barrel",
	type = "active",
	started = false,
	finished = false,
}

// Event methods

function event.explodeBarrel( barrel )

	local e = EffectData()
	e:SetOrigin( barrel:GetPos() )
	e:SetScale( 1 )
			
	util.Effect( "Explosion",e )
			
	barrel:Remove()
	hook.Remove( "Think","barrelthink" )
	event.finished = true
end

function event.main()
	
	local barrel = createClientModel( "models/props_c17/oildrum001_explosive.mdl" )
	
	timer.Create( "attemptplacebarrel",.1,0,function()
	
		if ( barrel:IsValid() ) then 
	
			local eyeAngles = quickAngles() 
		
			local pos = LocalPlayer():GetPos() + eyeAngles:Forward() * 250
		
			local collisionTrace = quickTrace( LocalPlayer():GetPos() + Vector( 0,0,40 ),pos + Vector( 0,0,40 ) )
			
			if ( !collisionTrace.Hit && canBlink ) then
				
				local surfaceTrace = quickTrace( pos + Vector( 0,0,80 ),pos - Vector( 0,0,9999 ) )
				
				barrel:SetPos( surfaceTrace.HitPos )
				timer.Destroy( "attemptplacebarrel" )
			end
		end
	end )
	
	hook.Add( "Think","barrelthink",function()
	
		barrel:SetAngles( barrel:GetAngles() + Angle( 0,1,0 ) )
	
		if ( barrel:GetPos():Distance( LocalPlayer():GetPos() ) < 50 ) then
		
			event.explodeBarrel( barrel )
			fakeDeath()
		end
	end )
	
	timer.Simple( 20,function()
		
		if ( barrel:IsValid() ) then
		
			event.explodeBarrel( barrel )
		end
	end )
end

// Add event

addEvent( event )
