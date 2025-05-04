local http_service = game:GetService("HttpService")

local Forms = {

	{'Kaioken', 0},
	{'FSSJ', 0},
	{'SSJ', 0},
	{'SSJ Kaioken', 0},
	{'SSJ2', 0},
	{'SSJ2 Majin', 0},
	{'Spirit SSJ', 0},
	{'SSJ3', 0},
	{'LSSJ', 0},
	{'Mystic', 0},
	{'SSJ4', 0},
	{'SSJG', 0},
	{'SSJ Rage', 0},
	{'Corrupt SSJ', 0},
	{'SSJB2', 0},
	{'SSJR2', 0},
	{'SSJ5', 0},
	{'SSJ Blue', 0},
	{'SSJ Rose', 0},
	{'SSJB Kaioken', 0},
	{'True Rose', 0},
	{'SSJ Berserker', 0},
	{'Kefla SSJ2', 0},
	{'Dark Rose', 0},
	{'Blue Evolution', 0},
	{'Evil SSJ', 0},
	{'Ultra Instinct Omen', 0},
	{'Godly SSJ2', 0},
	{'Mastered Ultra Instinct', 0},
	{'Jiren Ultra Instinct', 0},
	{'God of Destruction', 0},
	{'God of Creation', 0},
	{'SSJR3', 0},
	{'SSJB3', 0},
	{'LBSSJ4', 0},
	{'LBLSSJ4', 0},
	{'Ultra Ego', 0},
	{'SSJBUI', 0},
	{'Beast', 0},
	{'Ego Instinct', 0},
	{'Great Ape', 0},
	{"Astral Instinct", 0},
	{'Divine Rose Prominence',0},
	{'Divine Blue', 0},
	{"Great Ape", false}, --// TEMP
	{"Special Beam Cannon", false}, -- these check if you own em
	{"Jack-o'-Lantern Blast", false}, -- these check if you own em
	{"Destruction Beam", false}, -- these check if you own em
	{"Rock Impact", false},

}
local Stats = { --{nameofValue, defaultValue}
	{'Strength', 0},
	{'Energy', 0},
	{'Speed', 0},
	{'Defense', 0},
	{'Rebirth', 0}, --// TEMP
	{'Money', 0},
	{'SideSwitch', 0},

	{'Exploited', false},
	{'ExploitedKick', false},

	{'EBoost', 0},
	{'HBTC', 0},
	{'GR', 0},
	{"Easter Bunny Skips",0},
	{"Easter Bunny Cooldown",0},

	{"Senzu",0},

	{'Allignment', 'Good'},

	{'Quest', ''},
	{'QuestProgress', 0},

	{'Freshie', 0},

	


	{"UnlockedSkills", http_service:JSONEncode("[]")},
	{"Great Ape Barrage", false},
	{"Changed2", true},
	{"Changed3", true},
	{"Changedam2", 0},
	{"Changedam3", true},

	{"Changed4", true},
	{"Changed6", true},
	{"Restored11",true},
	{"JoinTime",os.time()},
	{"Rebirth Cooldown", 0},
	{"Version", game.ReplicatedStorage:WaitForChild("Package"):WaitForChild("GameVersion").Value}

}

local Customization = {
	{'Hair', 'Hair1'},
	{'Outfit', 'Outfit1'},
	{'Face', 'Face1'},
	{'Skin Color', 5},
	{'Energy Color', 92},
	{'Eye Color', 92},
	{'Hair Color', 93},
}
local SlotTemplate = {
	Version = 2,
	EBoost = 0,
	Quest = "",
Stats = {
	Strength= 0,
	Speed = 0,
	Energy = 0,
	Exp = 1,
	Defense = 0,
		Rebirth = 0,
	Suppression = 100
},

Currency = {
	Zeni = 500
},
Forms = {
},
Customization = {
	Hair = "Goku",
	Face = "Goku",
	Outfit = "Goku"
},
Inventory = {
	
},
Status = {
	AdminLevel = "Player",
	Banned = false,
	
},
Gamepasses = {
	
}

}

for i,v in Forms do
	SlotTemplate.Forms[v[1]] = v[2]
end
for i,v in Stats do
	SlotTemplate.Stats[v[1]] = v[2]
end
for i,v in Customization do 
	SlotTemplate.Customization[v[1]] = v[2]
end
spawn(function()
repeat wait(.1) until _G.Gamepasses
for i,v in _G.Gamepasses do
	SlotTemplate.Gamepasses[i] = false
end
end)
--warn(SlotTemplate)
return SlotTemplate