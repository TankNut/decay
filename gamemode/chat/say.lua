local CHAT = {}

CHAT.Commands = {"say"}

if CLIENT then
	function CHAT:Receive(ply, text)
		ply:AddChatLine(text, ply:GetChatFont(), 5, 1, ply:GetChatColor():ToColor())
	end
else
	function CHAT:Parse(ply, text)
		local snd = ply:RunPlayerClass("GetChatSound")

		if snd then
			ply:EmitSound(snd)
		end

		GAMEMODE:SendChatMessage(self.Name, ply, text)
	end
end

GM:AddChatCommand("Say", CHAT)
