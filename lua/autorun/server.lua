//
/*

	Creeps server.lua
	
	Forces client to download creeps content
	
	Made by Nautical
*/

if ( CLIENT ) then return end

// Lua

local events = file.Find( "lua/autorun/client/events/*.lua","GAME" )
	
for k,v in pairs( events ) do
	
	AddCSLuaFile( "client/events/"..v )
	MsgC( Color( 255,150,150,255 ),"[ Creeps Server ] added file: client/events/" .. v .. "\n" )
end

AddCSLuaFile( "client/main.lua" )

// Resources

local function addDir( dir )

	local files = file.Find( dir,"GAME" )
	
	local path = string.gsub(dir,"*","",1)

	for k,v in pairs( files ) do
	
		resource.AddSingleFile( path .. v )
		
		MsgC( Color( 255,150,150,255 ),"[ Creeps Server ] added resource: " .. v .. "\n" )
	end
end

addDir( "sound/creeps/*" )

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
		maximumBrightness			= 110, // Maximum environment brightness in which an event can take place
		debugMode					= 1, // enables debug printing
		eventChance					= 100, // 0% - 100% chance of event occuring
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
		maximumBrightness			= 110, // Maximum environment brightness in which an event can take place
		debugMode					= 0, // enables debug printing
		eventChance					= 25, // 0% - 100% chance of event occuring
	}
	
	net.Start("CREEPS_CONFIG_BROADCAST")
		
		net.WriteTable(newConfig)
	net.Send(targetPlayer)
	
	privateMessage(ply,"Disabled events on " .. targetPlayer:Nick())
end )