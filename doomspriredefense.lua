wait(2) -- Give the game a moment to load

-- Vote for Easy difficulty at the start
local vote_args = {
	"Easy"
}
game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Game"):WaitForChild("Vote"):FireServer(unpack(vote_args))
print("Voted for Easy difficulty.")
wait(2) -- Small delay after voting

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlaceTowerEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Game"):WaitForChild("PlaceTower")
local RestartEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Game"):WaitForChild("Restart")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Leaderstats = LocalPlayer:WaitForChild("leaderstats")
local Cash = Leaderstats:WaitForChild("Cash")
local Workspace = game:GetService("Workspace")
local TowersFolder = Workspace:WaitForChild("Towers")

local function wait_for_cash(required_cash)
	while Cash.Value < required_cash do
		print(string.format("Waiting for %d cash. Current cash: %d...", required_cash, Cash.Value))
		wait(1) -- Wait for 1 second before checking again
	end
end

local function execute_placement(args)
	PlaceTowerEvent:InvokeServer(unpack(args))
	wait(0.5) -- Small delay between actions
end

-- Tower placement and upgrade sequence with cash checks and waiting
local tower_coordinates = {
	-- Brawlers (Towers 1-6)
	{name = "Battler", coords = CFrame.new(19.63054847717285, -0.9000020027160645, 23.28512954711914)}, -- Tower 1
	{name = "Battler", coords = CFrame.new(19.740514755249023, -0.9000020027160645, 20.50560188293457)}, -- Tower 2
	{name = "Battler", coords = CFrame.new(21.074359893798828, -0.9000020027160645, 23.234867095947266)}, -- Tower 3
	{name = "Battler", coords = CFrame.new(21.267433166503906, -0.9000020027160645, 20.724044799804688)}, -- Tower 4
	{name = "Battler", coords = CFrame.new(22.415382385253906, -0.9000020027160645, 23.079076766967773)}, -- Tower 5
	{name = "Battler", coords = CFrame.new(22.624839782714844, -0.9000020027160645, 20.87070083618164)}, -- Tower 6
	-- Arsenals (Towers 7-9)
	{name = "Arsenal", coords = CFrame.new(17.752391815185547, -0.9000020027160645, 24.25379753112793)}, -- Tower 7
	{name = "Arsenal", coords = CFrame.new(20.620532989501953, -0.9000020027160645, 25.12689971923828)}, -- Tower 8
	{name = "Arsenal", coords = CFrame.new(18.12893295288086, -0.9000020027160645, 26.616981506347656)}, -- Tower 9
	-- Boombox (Tower 10)
	{name = "Boombox", coords = CFrame.new(23.166711807250977, -0.9000020027160645, 25.23324203491211)}, -- Tower 10
	-- Heavy Gunner (Tower 11)
	{name = "Heavy Gunner", coords = CFrame.new(13.817549705505371, -0.9000020027160645, 22.14163589477539)}, -- Tower 11
}

local tower_costs = {
	["Battler"] = 200,
	["Arsenal"] = 600,
	["Boombox"] = 1000,
	["Heavy Gunner"] = 4950,
}

local upgrade_costs = {
	["Battler"] = {150, 400},       -- 2 upgrades
	["Arsenal"] = {1000, 2200, 5000, 10000}, -- 4 upgrades
	["Boombox"] = {2200, 5000},      -- 2 upgrades
	["Heavy Gunner"] = {5525, 8000}, -- 2 upgrades
}

local placed_towers = {}

-- Place and upgrade the first 6 Brawlers
for i = 1, 6 do
	local tower_info = tower_coordinates[i]
	local tower_name = tower_info.name
	local placement_cost = tower_costs[tower_name]

	wait_for_cash(placement_cost)
	local args = {tower_name, tower_info.coords}
	execute_placement(args)
	Cash.Value = Cash.Value - placement_cost
	local placed_tower = TowersFolder:WaitForChild(tostring(i))
	table.insert(placed_towers, placed_tower)
	print(string.format("Placed %s (Tower %d) for %d cash. Remaining cash: %d", tower_name, i, placement_cost, Cash.Value))

	-- Upgrade the placed Brawler twice
	local upgrade_costs_brawler = upgrade_costs["Battler"]
	for upgrade_level = 1, #upgrade_costs_brawler do
		local upgrade_cost = upgrade_costs_brawler[upgrade_level]
		wait_for_cash(upgrade_cost)
		local args = {placed_tower, placed_tower.CFrame, true} -- Assuming 'true' for upgrade
		execute_placement(args)
		Cash.Value = Cash.Value - upgrade_cost
		print(string.format("Upgraded Battler (Tower %d) level %d for %d cash. Remaining cash: %d", i, upgrade_level, upgrade_cost, Cash.Value))
	end
end

-- Place and upgrade the next 3 Arsenals
for i = 7, 9 do
	local tower_info = tower_coordinates[i]
	local tower_name = tower_info.name
	local placement_cost = tower_costs[tower_name]

	wait_for_cash(placement_cost)
	local args = {tower_name, tower_info.coords}
	execute_placement(args)
	Cash.Value = Cash.Value - placement_cost
	local placed_tower = TowersFolder:WaitForChild(tostring(i))
	table.insert(placed_towers, placed_tower)
	print(string.format("Placed %s (Tower %d) for %d cash. Remaining cash: %d", tower_name, i - 6, placement_cost, Cash.Value))

	-- Upgrade the placed Arsenal three times
	local upgrade_costs_arsenal = upgrade_costs["Arsenal"]
	for upgrade_level = 1, math.min(#upgrade_costs_arsenal, 3) do
		local upgrade_cost = upgrade_costs_arsenal[upgrade_level]
		wait_for_cash(upgrade_cost)
		local args = {placed_tower, placed_tower.CFrame, true} -- Assuming 'true' for upgrade
		execute_placement(args)
		Cash.Value = Cash.Value - upgrade_cost
		print(string.format("Upgraded Arsenal (Tower %d) level %d for %d cash. Remaining cash: %d", i - 6, upgrade_level, upgrade_cost, Cash.Value))
	end
end

-- Place and upgrade the Boombox twice
local boombox_info = tower_coordinates[10]
local boombox_name = boombox_info.name
local boombox_placement_cost = tower_costs[boombox_name]

wait_for_cash(boombox_placement_cost)
local args = {boombox_name, boombox_info.coords}
execute_placement(args)
Cash.Value = Cash.Value - boombox_placement_cost
local placed_boombox = TowersFolder:WaitForChild("10")
table.insert(placed_towers, placed_boombox)
print(string.format("Placed %s (Tower 10) for %d cash. Remaining cash: %d", boombox_name, boombox_placement_cost, Cash.Value))

-- Upgrade the Boombox twice
local upgrade_costs_boombox = upgrade_costs["Boombox"]
for upgrade_level = 1, #upgrade_costs_boombox do
	local upgrade_cost = upgrade_costs_boombox[upgrade_level]
	wait_for_cash(upgrade_cost)
	local args = {placed_boombox, placed_boombox.CFrame, true} -- Assuming 'true' for upgrade
	execute_placement(args)
	Cash.Value = Cash.Value - upgrade_cost
	print(string.format("Upgraded Boombox (Tower 10) level %d for %d cash. Remaining cash: %d", upgrade_level, upgrade_cost, Cash.Value))
end

-- Upgrade the last two placed Arsenals (Towers 8 and 9) one more time (to level 4)
for i = 8, 9 do
	local tower_index = i
	local placed_arsenal = TowersFolder:WaitForChild(tostring(tower_index))
	local upgrade_costs_arsenal = upgrade_costs["Arsenal"]
	local next_upgrade_level = 4

	if upgrade_costs_arsenal[next_upgrade_level] then
		local upgrade_cost = upgrade_costs_arsenal[next_upgrade_level]
		wait_for_cash(upgrade_cost)
		local args = {placed_arsenal, placed_arsenal.CFrame, true} -- Assuming 'true' for upgrade
		execute_placement(args)
		Cash.Value = Cash.Value - upgrade_cost
		print(string.format("Upgraded Arsenal (Tower %d) to level %d for %d cash. Remaining cash: %d", tower_index - 6, next_upgrade_level, upgrade_cost, Cash.Value))
	else
		print(string.format("Arsenal (Tower %d) cannot be upgraded to level %d.", tower_index - 6, next_upgrade_level))
	end
end

-- Place and upgrade the Heavy Gunner twice
local heavy_gunner_info = tower_coordinates[11]
local heavy_gunner_name = heavy_gunner_info.name
local heavy_gunner_placement_cost = tower_costs[heavy_gunner_name]

wait_for_cash(heavy_gunner_placement_cost)
local args = {heavy_gunner_name, heavy_gunner_info.coords}
execute_placement(args)
Cash.Value = Cash.Value - heavy_gunner_placement_cost
local placed_heavy_gunner = TowersFolder:WaitForChild("11")
table.insert(placed_towers, placed_heavy_gunner)
print(string.format("Placed %s (Tower 11) for %d cash. Remaining cash: %d", heavy_gunner_name, heavy_gunner_placement_cost, Cash.Value))

-- Upgrade the Heavy Gunner twice
local upgrade_costs_heavy_gunner = upgrade_costs["Heavy Gunner"]
for upgrade_level = 1, #upgrade_costs_heavy_gunner do
	local upgrade_cost = upgrade_costs_heavy_gunner[upgrade_level]
	wait_for_cash(upgrade_cost)
	local args = {placed_heavy_gunner, placed_heavy_gunner.CFrame, true} -- Assuming 'true' for upgrade
	execute_placement(args)
	Cash.Value = Cash.Value - upgrade_cost
	print(string.format("Upgraded %s (Tower 11) level %d for %d cash. Remaining cash: %d", heavy_gunner_name, upgrade_level, upgrade_cost, Cash.Value))
end

-- Wait for 30 seconds before restarting
wait(60)
RestartEvent:FireServer()
print("Restarted the game after 30 seconds.")
