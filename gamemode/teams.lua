GM.Teams = {}

function GM:AddTeam(name, color)
	local id = #self.Teams + 1

	self.Teams[id] = {
		Id = id,
		Name = name,
		Color = color
	}

	return id
end

function GM:CreateTeams()
	for _, data in ipairs(self.Teams) do
		team.SetUp(data.Id, data.Name, data.Color)
	end
end
