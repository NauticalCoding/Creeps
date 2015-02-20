//
/*

	FlashlightFlicker passive event
	
	Nautical
*/

local event = {

	type = "passive",
	name = "Flashlight Flicker",
	started = false,
	finished = false,
}

function event.main()
	
	if (approxBrightness() < 75 && LocalPlayer():FlashlightIsOn()) then
	
		local runs = 0

		timer.Create("CREEPS_flickerFlashlight",.15,10,function()
	
	
			local delay = math.random(1,10) / 10
		
			timer.Simple(delay,function()
				RunConsoleCommand("impulse","100")
			end)
		
			runs = runs + 1
			
			if (runs == 10) then
			
				event.finished = true
			end
		end)
	else
	
		event.finished = true
	end
end

// add event

addEvent(event)