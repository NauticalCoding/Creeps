//
/* 

	Ghost mode event
	
	Made by Nautical
*/

// Event vars

local event = {
	
	name = "Ghost mode",
	type = "active",
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

event.modifiedEnts = {}

// Event methods

function event.setNoRender( bool )
	
	if (bool) then
	
		for k,v in pairs( ents.GetAll() ) do
		
			if ( !v:IsValid() ) then continue end
			if ( v:GetModel() == "models/combine_helicopter/helicopter_bomb01.mdl" ) then 
				
				continue 
			end
			
			if (!quickTrace(LocalPlayer():GetShootPos(),v:GetPos(),{LocalPlayer(),v}).Hit) then
				if (!table.HasValue(event.modifiedEnts,v)) then
				
					if ( v:IsPlayer() ) then
		
						if ( !v:IsMuted() ) then
						
							v:SetMuted(true)
						end
					end
					
					v:SetNoDraw(true)
					table.insert(event.modifiedEnts,v)
				end
				
			elseif(table.HasValue(event.modifiedEnts,v)) then
			
				table.remove(event.modifiedEnts,table.KeyFromValue(event.modifiedEnts,v))
				v:SetNoDraw(false)
			end
		end
	else
	
		for k,v in pairs(event.modifiedEnts) do
	
			if (!v:IsValid()) then continue end
			
			if (v:IsPlayer()) then
			
				if (v:IsMuted()) then
	
					v:SetMuted(false)
				end
			end
			
			v:SetNoDraw(false)
		end
		
		event.modifiedEnts = {}
	end
end

function event.main()
	
	timer.Create( "CREEPS_setNoRender",.1,0,function()
		
		event.setNoRender( true )
	end )
	
	surface.PlaySound( table.Random( event.sounds ) )
	
	hook.Add( "RenderScreenspaceEffects","CREEPS_blacknwhite",function()
	
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
	
		pos = ( LocalPlayer():GetPos() + Vector( 0,0,15 ) ) + eyeAngles:Forward() * 50
	end
	
	hook.Add( "Think","CREEPS_checkDistance",function()
		
		orb:SetPos( pos + Vector( 0,0,TimedSin( 1, 0, 15, 0 ) ) )
		
		if ( LocalPlayer():GetPos():Distance( orb:GetPos() ) < 45 || !LocalPlayer():Alive() ) then
			
			orb:Remove()
			
			blink()
			
			timer.Destroy( "CREEPS_setNoRender" )
			hook.Remove( "RenderScreenspaceEffects","CREEPS_blacknwhite" )
			hook.Remove( "Think","CREEPS_checkDistance" )
			RunConsoleCommand( "stopsound" )
			
			event.setNoRender( false )
			event.finished = true
		end
	end )
end

// Add event

addEvent( event )