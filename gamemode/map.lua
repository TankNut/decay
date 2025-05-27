function GM:LoadMapFile()
	if SERVER then
		self:LoadMapEntities()
	end
end

if SERVER then
	function GM:LoadMapEntities()
		if not self.MapEntities then
			return
		end

		for _, data in ipairs(self.MapEntities) do
			local class, pos, ang = unpack(data, 1, 3)
			local ent = ents.Create(class)

			ent:SetPos(pos)
			ent:SetAngles(ang)

			ent:SetupMapEntity(unpack(data, 4))

			ent:Spawn()
		end
	end
end
