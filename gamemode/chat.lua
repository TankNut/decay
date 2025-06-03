if CLIENT then
	function GM:ProcessChat(ply, text)
		ply:AddChatLine(text, ply:GetChatFont(), 5, 1, ply:GetChatColor():ToColor())
	end

	net.Receive("PlayerChat", function()
		local ply = net.ReadPlayer()

		if not IsValid(ply) then
			return
		end

		hook.Run("ProcessChat", ply, net.ReadString())
	end)
else
	function GM:PlayerSay(ply, text)
		local snd = ply:RunPlayerClass("GetChatSound")

		if snd then
			ply:EmitSound(snd)
		end

		net.Start("PlayerChat")
			net.WritePlayer(ply)
			net.WriteString(text)
		net.Broadcast()

		return ""
	end

	util.AddNetworkString("PlayerChat")
end
