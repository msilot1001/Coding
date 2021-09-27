local SettingsFolder = script.Parent.Parent.Settings.BanServiceSettings

local BanService = {
	BanDatastoreName = SettingsFolder.BanDatastoreName.Value;
	BanDefaultReason = SettingsFolder.BanDefaultReason.Value;
}

local DS2 = require(1936396537)
local mc = require(script.Parent.Parent.ModuleComponents)

function BanService:CheckBan(player)
	mc:params({"Instance"}, {player}, 1)
	
	local Data = DS2(self.BanDatastoreName, player):GetTable({IsBanned = false; Reason = "", BanTime = 0})
	return Data.IsBanned, Data.Reason, Data.BanTime
end

function BanService:BanPlayer(player, reason, banTime)
	mc:params({"Instance", "string", "number"}, {player, reason, banTime}, 1)
	
	local reason = reason or self.BanDefaultReason
	DS2(self.BanDatastoreName, player):Set({IsBanned = true; Reason = reason, Time = banTime and os.time() + banTime})
	player:Kick(reason)
end

function BanService:Init(bool)
	local InbuiltEvent
	
	if bool then
		InbuiltEvent = Instance.new("BindableEvent")
		InbuiltEvent.Name = "kickedBannedPlayer"
		InbuiltEvent.Parent = game:GetService("ReplicatedStorage").InbuiltEvents
	end
	
	local connection do
		connection = game:GetService("Players").PlayerAdded:Connect(function(player)
			local isBanned, reason, banTime = BanService:CheckBan(player)
		
			if isBanned then
				if banTime and banTime < os.time() then
					local store = DS2(self.BanDatastoreName, player)
					store:Set({IsBanned = false, Reason = "", Time = 0})
					store:Save()
				else
					InbuiltEvent:Fire(player, reason)
					player:Kick(reason)
				end
			end
		end)
	end
	
	return connection
end

return BanService
