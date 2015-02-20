//
/* 

	Encase event
	
	Made by Nautical
*/

// Event vars

local event = {
	
	name = "Encase",
	type = "active",
	started = false,
	finished = false,
}

event.offsets = {

	{ Type = 1,Mult = 1,Ang = Angle( 0,180,0 ) }, // Type,Multiplier,Angle offset
	{ Type = 1,Mult = -1,Ang = Angle( 0,0,0 ) },
	{ Type = 2,Mult = 1,Ang = Angle( 0,90,0 ) },
	{ Type = 2,Mult = -1,Ang = Angle( 0,-90,0 ) },
}

event.sounds = {

	placeWall = "physics/metal/metal_box_break1.wav",
	metalMove = "ambient/materials/metal_rattle.wav",
	
	crush = {

		"creeps/NeckSnap1.wav",
		"creeps/NeckSnap3.wav",
	}
}

// Event methods

function event.main()
	
	local distance = 100
	local eyeAngles = quickAngles()
	local wallsPlaced = {}
	local hasMetalMoved = false
	local forcePlaceWalls = false
	
	timer.Simple( 5,function()
		
		forcePlaceWalls = true
	end )
	
	
	hook.Add( "Think","encasethink",function()
	
		// Restrict movement
		
		if ( input.IsKeyDown( KEY_W ) ) then
		
			RunConsoleCommand( "-forward" )
		end
		
		if ( input.IsKeyDown( KEY_S ) ) then
		
			RunConsoleCommand( "-back" )
		end
		
		if ( input.IsKeyDown( KEY_A ) ) then
		
			RunConsoleCommand( "-moveleft" )
		end
		
		if ( input.IsKeyDown( KEY_D ) ) then
		
			RunConsoleCommand( "-moveright" )
		end
		
		// Place walls
	
		for k,v in pairs( event.offsets ) do
		
			if ( wallsPlaced[ k ] != nil ) then continue end
			
				local worldPos = LocalPlayer():GetPos()
			
				if ( v.Type == 1 ) then
			
					worldPos = worldPos + eyeAngles:Forward() * v.Mult * distance
				else
				
					worldPos = worldPos + eyeAngles:Right() * v.Mult * distance
				end
			
			if ( inFOV( worldPos ) || forcePlaceWalls ) then
					
				surface.PlaySound( event.sounds.placeWall )
					
				wallsPlaced[ k ] = createClientModel( "models/props_lab/blastdoor001c.mdl" )
				wallsPlaced[ k ]:SetPos( worldPos )
				wallsPlaced[ k ]:SetAngles( eyeAngles + v.Ang )
			end
		end
		
		// Crush player
		
		if ( table.Count( wallsPlaced ) == 4 ) then
			
			if ( !hasMetalMoved ) then
			
				surface.PlaySound( event.sounds.metalMove )
				hasMetalMoved = true
			end
		
			distance = distance - .5
			
			if ( distance > 20 ) then
			
				for k,v in pairs( wallsPlaced ) do
				
					v:SetPos( LocalPlayer():GetPos() - v:GetAngles():Forward() * distance ) 
				end
			else
			
				surface.PlaySound( table.Random( event.sounds.crush ) )
			
				fakeDeath()
				
				hook.Remove( "Think","encasethink" )
				
				for k,v in pairs( wallsPlaced ) do
				
					v:Remove()
				end
				
				event.finished = true
			end
		end
	end )
end

// Add event

addEvent( event )