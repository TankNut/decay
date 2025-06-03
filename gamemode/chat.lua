GM.ChatCommands = {}
GM.ChatLookup = {}

function GM:AddChatCommand(name, data)
	self.ChatCommands[name] = data

	data.Name = name

	if data.Commands then
		for _, command in ipairs(data.Commands) do
			self.ChatLookup[string.lower(command)] = data
		end
	end
end

if CLIENT then
	net.Receive("Chat", function()
		GAMEMODE.ChatCommands[net.ReadString()]:Receive(unpack(net.ReadTable(true)))
	end)
else
	function GM:SendChatMessage(name, ...)
		net.Start("Chat")
			net.WriteString(name)
			net.WriteTable({...}, true)
		net.Broadcast()
	end

	function GM:PlayerSay(ply, text)
		local command, args = string.match(text, "^[/!](%w+)%s*(.-)%s*$")

		if not command then
			command = "say"
			args = text
		end

		command = self.ChatLookup[string.lower(command)]

		if not command then
			return
		end

		command:Parse(ply, args)

		return ""
	end

	util.AddNetworkString("Chat")
end
