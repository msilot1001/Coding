--[[
	Documentation: https://github.com/return-end1/Velocity/wiki
	
	Example of use:
	
		local module = require(game:GetService("ReplicatedStorage").Velocity)
		module:SetSetting("LeaderstatsName", "plrStats")
		local velocity = module:Init(true)	
	
		local stat = velocity:GetService("LeaderstatService")
		local ies = velocity:GetService("InbuiltEventsService")
		local cs = velocity:GetService("CommunicationService")
		local ds2 = velocity:GetModule("DataStore2")
		cs:new("Incremented")

		ies.playerAdded:Connect(function(player)
			local store = ds2("cheese", player)
			local stats = stat:MakeStats(player)
			local cheese = stat:CreateStat(player, "NumberValue", store:Get(10), "cheese")
	
			stat:UpdateStat(player, "cheese", 20)
			stat:IncrementStat(player, "cheese", 20)
	
			stat:TimedIncrement(player, "cheese", 20, 5, false, function(newVal)
				
				store:Set(newVal)
   	        	cs:fire("Increment", false, player, newVal)
			end)
		end)
	
--]]
