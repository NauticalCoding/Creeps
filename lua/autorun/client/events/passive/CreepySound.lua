//
/*

	CreepySound passive event
	
	Nautical
*/

local event = {

	type = "passive",
	name = "CreepySound",
	started = false,
	finished = false,
}

event.sounds = {

	"creeps/Ambient5.wav",
	"creeps/Ambient6.wav",
	"creeps/Ambient11.wav",
	"creeps/Ambient13.wav",
	"creeps/Ambient9.wav",
	"creeps/Ambient16.wav",
	"creeps/Ambient19.wav",
	"creeps/Ambient17.wav",
}

function event.main()

	if (approxBrightness() < 75) then

		local soundPatch = CreateSound(LocalPlayer(),table.Random(event.sounds))
		soundPatch:ChangeVolume(.5,.1)
		soundPatch:Play()
		event.finished = true
	else
	
		event.finished = true
	end
end

// add event

addEvent(event)