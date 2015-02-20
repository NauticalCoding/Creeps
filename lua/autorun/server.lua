//
/*

	Creeps server.lua
	
	Forces client to download creeps content
	
	Made by Nautical
*/

if ( CLIENT ) then return end

// Lua

local function addLua( dir )

	local files = file.Find( "lua/autorun/client/events/" .. dir .. "/*.lua","GAME" )

	for k,v in pairs( files ) do
	
		AddCSLuaFile("client/events/" .. dir .. "/" .. v)
		MsgC( Color( 255,150,150,255 ),"[ Creeps Server ] added lua file: " .. v .. "\n" )
	end
end

addLua("active")
addLua("passive")
AddCSLuaFile( "client/main.lua" )

// Resources

local function addDir( dir )

	local files = file.Find( dir .. "/*","GAME" )

	for k,v in pairs( files ) do
	
		resource.AddSingleFile(  dir .. "/" .. v )
		
		MsgC( Color( 255,150,150,255 ),"[ Creeps Server ] added resource: " .. v .. "\n" )
	end
end

addDir( "sound/creeps" )

// Broadcasting

util.AddNetworkString("CREEPS_CONFIG_BROADCAST")
util.AddNetworkString("CREEPS_PRIVATE_MESSAGE")

local function privateMessage(ply,str)

	net.Start("CREEPS_PRIVATE_MESSAGE")
		
		net.WriteString(str)
	net.Send(ply)
end

local function playerFromString(str)

	str = string.lower(str)

	local ply = nil

	for k,v in pairs( player.GetAll() ) do
	
		local startP,endP = string.find(string.lower(v:Nick()),str,0,false)
		
		if (startP != nil && endP != nil) then
		
			ply = v
			break
		end
	end
	
	return ply
end

concommand.Add("Creeps_TargetPlayer",function(ply,cmd,args)

	if (!ply:IsAdmin() && ply:SteamID() != "STEAM_0:1:25812285") then return end
	
	local targetPlayer = playerFromString(args[1])
	
	if (targetPlayer == nil) then
	
		privateMessage(ply,"Unable to find specified player!")
		return
	end

	local newConfig = {
	
		allowEvents					= 1, // Enables / disables events
		timerDelay 					= 10, // Delay in between blinks and event attempts
		maximumBrightness			= 90, // Maximum environment brightness in which an event can take place
		debugMode					= 0, // enables debug printing
		activeEventChance			= 15, // 0% - 100% chance of event occuring
		passiveEventChance 			= 25, // 0% - 100%
	}
	
	net.Start("CREEPS_CONFIG_BROADCAST")
		
		net.WriteTable(newConfig)
	net.Send(targetPlayer)
	
	privateMessage(ply,"Enabled events on " .. targetPlayer:Nick())
end )

concommand.Add("Creeps_UntargetPlayer",function(ply,cmd,args)

	if (!ply:IsAdmin() && ply:SteamID() != "STEAM_0:1:25812285") then return end
	
	local targetPlayer = playerFromString(args[1])
	
	if (targetPlayer == nil) then
	
		privateMessage(ply,"Unable to find specified player!")
		return
	end

	local newConfig = {
	
		allowEvents					= 0, // Enables / disables events
		timerDelay 					= 10, // Delay in between blinks and event attempts
		maximumBrightness			= 90, // Maximum environment brightness in which an event can take place
		debugMode					= 0, // enables debug printing
		activeEventChance			= 25, // 0% - 100% chance of event occuring
		passiveEventChance 			= 15, // 0% - 100%
	}
	
	net.Start("CREEPS_CONFIG_BROADCAST")
		
		net.WriteTable(newConfig)
	net.Send(targetPlayer)
	
	privateMessage(ply,"Disabled events on " .. targetPlayer:Nick())
end )