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

		for i = 1,10 do
	
			local offset = math.random(1,10) / 10
		
			timer.Simple( ( i / 10 ) + offset,function()
				RunConsoleCommand("impulse","100")
			end)
		
			if (i == 10) then
			
				event.finished = true
			end
		end
	else
	
		event.finished = true
	end
end

// add event

addEvent(event)