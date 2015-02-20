//
/*

	BabyDrop event
	
	Nautical
*/

local event = {

	name = "BabyDrop",
	type = "active",
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
	
	local baby = createClientModel("models/props_c17/doll01.mdl")
	local monster = quickMonster()
	local babyPlaced = false
	local babyDrop = false
	local babyHitGround = false
	
	local infront = ( LocalPlayer():GetPos() + quickAngles():Forward() * 300 )
	
	timer.Create("CREEPS_babyDrop",.01,0,function()

		if (!babyPlaced) then
			if (!quickTrace(LocalPlayer():GetShootPos(),infront,{LocalPlayer()}).Hit) then
			
				baby:SetPos(infront + Vector(0,0,50))
				baby:SetAngles(Angle(0,0,0))
				
				local soundObj = CreateSound(baby,"creeps/children.wav")
				
				baby:EmitSound("creeps/children.wav",60,100,1,CHAN_VOICE)
				timer.Create("CREEPS_babyDropSoundEmit",9.1,0,function()
					
					if (baby:GetPos():Distance(LocalPlayer():GetPos()) < 1000) then
				
						baby:EmitSound("creeps/children.wav",60,100,1,CHAN_VOICE)
					end
				end)
				
				babyPlaced = true
			else
			
				infront = ( LocalPlayer():GetPos() + quickAngles():Forward() * 300 )
			end
			
		elseif (!babyDrop) then
		
			local angleToMe = ( (( LocalPlayer():GetPos() + LocalPlayer():GetVelocity() / 2 ) + Vector( 0,0,45 ) )  - baby:GetPos() ):Angle()
			
			baby:SetAngles(angleToMe)
			baby:SetPos(baby:GetPos() + angleToMe:Forward() * 3)

			if (LocalPlayer():GetPos():Distance(baby:GetPos()) < 200) then
			
				babyDrop = true
				timer.Destroy("CREEPS_babyDropSoundEmit")
			end
		end
		
		if (babyDrop && baby:IsValid()) then
		
			baby:SetPos(baby:GetPos() - Vector(0,0,5))
			
			if (baby:GetPos().z < infront.z) then
			
				surface.PlaySound(table.Random(event.sounds))
				babyHitGround = true
				blink()
				monster:SetPos(LocalPlayer():GetPos() + quickAngles():Forward() * 150)
				baby:Remove()
			end
		end
		
		if(babyHitGround) then
		
			local angleToMe = ( LocalPlayer():GetPos()  - monster:GetPos() ):Angle()
	
			monster:SetAngles( angleToMe )
			monster:SetPos(monster:GetPos() + angleToMe:Forward() * 15)
			
			if (monster:GetPos():Distance(LocalPlayer():GetPos()) <= 50) then
			
				timer.Destroy("CREEPS_babyDrop")
				monster:Remove()
				event.finished = true
			end
			
		end
	end )
end

// Add event

addEvent(event)