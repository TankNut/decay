AddCSLuaFile()
DEFINE_BASECLASS("player_base")

local PLAYER = {}

PLAYER.Weapons          = {
	"decay_hands",
	"weapon_physgun",
	"gmod_tool"
}

PLAYER.Hull             = {Vector(-10, -10, 0), Vector(10, 10, 72)}
PLAYER.DuckHull         = {Vector(-10, -10, 0), Vector(10, 10, 36)}

PLAYER.ViewOffset       = Vector(0, 0, 64)
PLAYER.ViewOffsetDucked = Vector(0, 0, 38)

PLAYER.SlowWalkSpeed    = 100
PLAYER.WalkSpeed        = 200
PLAYER.RunSpeed         = 400

PLAYER.InventoryRows    = 6
PLAYER.InventoryColumns = 3

if SERVER then
	function PLAYER:Spawn()
		BaseClass.Spawn(self)

		self.Player:SetCorpse(NULL)
	end

	function PLAYER:Spare1()
		local ply = self.Player

		if ply:HasInventory() then
			net.Start("OpenInventory")
			net.Send(ply)
		end
	end

	function PLAYER:Spare2()
		-- Drop weapon
	end
end

player_manager.RegisterClass("player_humanoid", PLAYER, "player_base")
