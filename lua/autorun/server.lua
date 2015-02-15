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
end

AddCSLuaFile( "client/main.lua" )

// Resources

local function addDir( dir )

	local files,directories = file.Find( dir,"GAME" )

	for k,v in pairs( files ) do
	
		resource.AddFile( dir .. "/" .. v )
		
		MsgC( Color( 255,150,150,255 ),"[ Creeps Server ] added resource: " .. v .. "\n" )
	end
	
	for k,v in pairs( directories ) do
	
		addDir( dir .. "/" .. v )
	end
end

addDir( "materials/models/synth/*" )
addDir( "models/elite_synth/*" )
addDir( "sound/creeps/*" )