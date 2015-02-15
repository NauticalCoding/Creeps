//
/*
	Creeps config.lua
	
	Used to configure how the creeps system functions
	
	Made by Nautical
*/

CREEPS = {
	
	[ "Allow_Events" ] 			= 1, // Enables / disables events
	[ "Timer_Delay" ] 			= 10, // Delay in between blinks and event attempts
	[ "Maximum_Brightness" ]	= 60, // Maximum environment brightness in which an event can take place
	[ "Debug_Mode" ] 			= 0, // enables debug printing
	[ "Event_Chance" ] 			= 10, // 0% - 100% chance of event occuring
}

for k,v in pairs( CREEPS ) do

	CreateClientConVar( "Creeps_" .. k,v,true,false )
end