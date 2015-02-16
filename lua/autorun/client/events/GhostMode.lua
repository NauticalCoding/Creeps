//
/* 

	Ghost mode event
	
	Made by Nautical
*/

// Local vars

local event = {
	
	name = "Ghost mode",
	started = false,
	finished = false,
}

event.sounds = {

	"ambient/atmosphere/tone_alley.wav",
	"ambient/atmosphere/tone_quiet.wav",
	"ambient/atmosphere/tunnel1.wav",
	"ambient/atmosphere/sewer_air1.wav",
	"creeps/Ambient5.wav",
	"creeps/Ambient6.wav",
	"creeps/Ambient11.wav",
	"creeps/Ambient13.wav",
}

// Local methods

function event.setNoRender( bool )

	for k,v in pairs( ents.GetAll() ) do
	
		if ( !v:IsValid() ) then continue end
		if ( v:GetModel() == "models/combine_helicopter/helicopter_bomb01.mdl" ) then 
			
			print( v:GetModel() )
			print( "skipping!" )
			continue 
		end
		
		if ( v:IsPlayer() ) then
		
			if ( bool ) then
			
				if ( !v:IsMuted() ) then
		
					v:SetMuted( bool )
				end
			else
			
				v:SetMuted( bool )
			end
		end
		
		v:SetNoDraw( bool )
	end
end

function event.main()
	
	timer.Create( "setnorender",1,0,function()
	
		event.setNoRender( true )
	end )
	
	surface.PlaySound( table.Random( event.sounds ) )
	
	hook.Add( "RenderScreenspaceEffects","blacknwhite",function()
	
		local tab = {}
		tab[ "$pp_colour_addr" ] = 0
		tab[ "$pp_colour_addg" ] = 0
		tab[ "$pp_colour_addb" ] = 0
		tab[ "$pp_colour_brightness" ] = 0
		tab[ "$pp_colour_contrast" ] = .85
		tab[ "$pp_colour_colour" ] = 0
		tab[ "$pp_colour_mulr" ] = 0
		tab[ "$pp_colour_mulg" ] = 0
		tab[ "$pp_colour_mulb" ] = 0 
	 
		DrawColorModify( tab )
	 
		//DrawBloom( 0, 0.75, 3, 3, 2, 3, 255, 255, 255 )
		//DrawMaterialOverlay( "effects/combine_binocoverlay.vmt", 0.1 )
		//DrawMaterialOverlay( "models/props_combine/com_shield001a",0.1 )
		DrawMotionBlur( 0.1, 0.79, 0.01 )
		//DrawSharpen( 1.991, 5 )
		//DrawSunbeams( 0.5 , 2, 5, 0, 0 )
	
	end )
	
	local eyeAngles = quickAngles() 
	
	local orb = createClientModel( "models/Combine_Helicopter/helicopter_bomb01.mdl" )
	orb:SetMaterial( "models/shiny" )
	
	local pos = ( LocalPlayer():GetPos() + Vector( 0,0,15 ) ) - eyeAngles:Forward() * 50
	
	if ( quickTrace( LocalPlayer():GetShootPos(),pos ).Hit ) then
	
	
		pos = ( LocalPlayer() + Vector( 0,0,15 ) ) + eyeAngles:Forward() * 50
	end
	
	local theta = 0
	
	hook.Add( "Think","checkdistance",function()
		
		theta = theta + .05
		
		if ( theta > 3.1 ) then
		
			theta = 0
		end
		
		orb:SetPos( pos + Vector( 0,0,math.sin( theta ) ) * 15 )
		
		if ( LocalPlayer():GetPos():Distance( orb:GetPos() ) < 45 || !LocalPlayer():Alive() ) then
			
			orb:Remove()
			
			blink()
			
			timer.Destroy( "setnorender" )
			hook.Remove( "RenderScreenspaceEffects","blacknwhite" )
			hook.Remove( "Think","checkdistance" )
			RunConsoleCommand( "stopsound" )
			
			event.finished = true
			event.setNoRender( false )
		end
	end )
end

// Add event

addEvent( event )