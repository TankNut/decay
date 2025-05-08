function GM:PrePlayerDraw(ply, flags)
	return player_manager.RunClass(ply, "PrePlayerDraw", flags)
end

function GM:PostPlayerDraw(ply, flags)
	return player_manager.RunClass(ply, "PostPlayerDraw", flags)
end
