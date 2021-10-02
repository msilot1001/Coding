local Damage = game.ReplicatedStorage.Damage
local Fire = game.ReplicatedStorage.Fire

Damage.OnServerEvent:Connect(function(client, player, damage)
    if player then
		player:FindFirstChild("Humanoid"):TakeDamage(damage)
	end
end)

Fire.OnServerEvent:Connect(function(client, origin, endposition)
	Fire:FireAllClients(client, origin, endposition)
end)


	