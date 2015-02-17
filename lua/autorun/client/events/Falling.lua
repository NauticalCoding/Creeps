//
/*

	Falling event
	
	Made by Nautical
*/

// Event vars

local event = {
	
	name = "Falling",
	started = false,
	finished = false,
}

event.viewData = {

	origin = Vector(0,0,0),
	angles = Angle(0,0,0),
	endPos = Vector(0,0,0), // my own variable
	x = 0,
	y = 0,
	w = ScrW(),
	h = ScrH(),
}

// Event methods

function event.drawFallingCamera()
	
	if (event.viewData.origin.z <= event.viewData.endPos.z) then
		
		fakeDeath()
		event.finished = true
		hook.Remove("HUDPaint","CREEPS_drawFallingCamera")
		
		return
	end
	
	event.viewData.origin = event.viewData.origin - Vector(0,0,event.cameraVelocity)
	event.viewData.angles = event.viewData.angles + event.cameraAngularVelocity
	event.cameraVelocity = event.cameraVelocity + .1
	event.cameraAngularVelocity = event.cameraAngularVelocity + Angle(-.001,0,.001)
	render.RenderView(event.viewData)
end

function event.main()

	event.cameraVelocity = 0
	event.cameraAngularVelocity = Angle(0,0,0)

	local trace = quickTrace(LocalPlayer():GetPos(),LocalPlayer():GetPos() + Vector( 0,0,9999),{LocalPlayer})

	event.viewData.origin = trace.HitPos - Vector(0,0,10)
	event.viewData.endPos = LocalPlayer():GetPos()
	event.viewData.angles = quickAngles() + Angle(89,0,0)

	surface.PlaySound("ambient/voices/m_scream1.wav")
	
	hook.Add("HUDPaint","CREEPS_drawFallingCamera",event.drawFallingCamera )
end

// Add event

addEvent(event)