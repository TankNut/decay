GM.Binds = GM.Binds or {}

function GM:AddBind(name, key, callback)
	local convar = "decay_key_" .. name

	self.Binds[name] = {
		Key = key,
		Convar = convar,
		Callback = callback
	}

	if CLIENT then
		CreateClientConVar(convar, key, true, true)
	end
end

GM:AddBind("toggleholster", KEY_B, function(ply, down)
	if not down then
		return
	end

	local weapon = ply:GetActiveWeapon()

	if IsValid(weapon) and weapon.ToggleHolster then
		weapon:ToggleHolster()

		return true
	end
end)

function GM:PlayerButtonDown(ply, key)
	for _, bind in pairs(self.Binds) do
		if key == ply:GetInfoNum(bind.Convar, bind.Key) and bind.Callback(ply, true) then
			return
		end
	end

	if SERVER then
		numpad.Activate(ply, key)
	end
end

function GM:PlayerButtonUp(ply, key)
	for _, bind in pairs(self.Binds) do
		if key == ply:GetInfoNum(bind.Convar, bind.Key) and bind.Callback(ply, false) then
			return
		end
	end

	if SERVER then
		numpad.Deactivate(ply, key)
	end
end
