local ConvertSuffix = _G.ConvertSuffix

return {
	["Vanish Strike"] = {
		Cost = 30,
		Requirements = {
			Energy = 0,
			Rebirth = 0,
			Speed = ConvertSuffix(40, "K"),  -- 40 thousand
			Strength = ConvertSuffix(40, "K"),
		},
	},
	["Vital Strike"] = {
		Cost = 5,
		Requirements = {
			Energy = 0,
			Rebirth = 0,
			Speed = 500,
			Strength = 500,
		},
	},
	["Wolf Fang Fist"] = {
		Cost = 30,
		Requirements = {
			Energy = 0,
			Rebirth = 0,
			Speed = ConvertSuffix(2, "K"),  -- 2 thousand
			Strength = ConvertSuffix(2, "K"),
		},
	},
	Kamehameha = {
		Cost = 20,
		Requirements = {
			Energy = 1500,
			Rebirth = 0,
			Speed = 0,
			Strength = 0,
		},
	},

	Masenko = {
		Cost = 10,
		Requirements = {
			Energy = 500,
			Rebirth = 0,
			Speed = 0,
			Strength = 0,
		},
	},

	Sledgehammer = {
		Cost = 20,
		Requirements = {
			Energy = 0,
			Rebirth = 0,
			Speed = ConvertSuffix(1, "K"),  -- 1 thousand
			Strength = ConvertSuffix(1, "K"),
		},
	},
	Supernova = {
		Allignment = "Evil",
		Cost = 150,
		DetectDuration = 2,
		Hitbox = Vector3.new(52, 52, 52),
		MaxTime = 15,
		Requirements = {
			Energy = ConvertSuffix(110, "K"),  -- 110 thousand
			Rebirth = 0,
			Speed = 0,
			Strength = 0,
		},
		SizeScale = 13,
	},
	Uppercut = {
		Cost = 20,
		Requirements = {
			Energy = 0,
			Rebirth = 0,
			Speed = ConvertSuffix(1, "K"),  -- 1 thousand
			Strength = ConvertSuffix(2, "K"),  -- 2 thousand
		},
	},
	["100x Big Bang Kamehameha"] = {
		Cost = 10000,
		MaxTime = 2,
		Requirements = {
			Energy = ConvertSuffix(80, "M"),  -- 80 million
			Rebirth = 0,
			Speed = 0,
			Strength = 0,
		},
	},
	["Angry Kamehameha"] = {
		Cost = 100,
		Requirements = {
			Energy = ConvertSuffix(70, "K"),  -- 70 thousand
			Rebirth = 0,
			Speed = 0,
			Strength = 0,
		},
	},
	["Astral Instinct"] = {
		Requirements = {
			Energy = ConvertSuffix(138, "M"),  -- 138 million
			Rebirth = 0,
			Speed = ConvertSuffix(138, "M"),
			Strength = ConvertSuffix(138, "M"),
		},
		Time = "Transform",
	},
	["Beast Cannon"] = {
		Cost = 10000,
		MaxTime = 2,
		Requirements = {
			Energy = ConvertSuffix(140, "M"),  -- 140 million
			Rebirth = 0,
			Speed = 0,
			Strength = 0,
		},
	},
	["Big Bang Attack"] = {
		Cost = 10,
		DetectDuration = 1,
		Hitbox = Vector3.new(26, 26, 26),
		Requirements = {
			Energy = ConvertSuffix(16, "K"),  -- 16 thousand
			Rebirth = 0,
			Speed = 0,
			Strength = 0,
		},
	},
	["Big Bang Kamehameha"] = {
		Cost = 1400,
		Gamepass = 6950465,
		Requirements = {
			Energy = ConvertSuffix(1.8, "M"),  -- 1.8 million
			Rebirth = 0,
			Speed = 0,
			Strength = 0,
		},
	},
	["Binding Black Kamehameha"] = {
		Allignment = "Evil",
		Cost = 30,
		Requirements = {
			Energy = ConvertSuffix(500, "M"),  -- 500 million
			Rebirth = 0,
			Speed = ConvertSuffix(500, "M"),
			Strength = ConvertSuffix(500, "M"),
		},
	},
	Destruction = {
		Allignment = "Evil",
		Cost = 5000,
		Gamepass = 9848987,
		MaxTime = 2,
		Requirements = {
			Energy = ConvertSuffix(40, "M"),  -- 40 million
			Rebirth = 0,
			Speed = 0,
			Strength = 0,
		},
	},

	Fusion = {
		Cost = 0,
		Requirements = {
			Energy = ConvertSuffix(1, "M"),  -- 1 million
			Rebirth = 0,
			Speed = ConvertSuffix(1, "M"),
			Strength = ConvertSuffix(1, "M"),
		},
	},


	["Bone Crusher"] = {
		Cost = 30,
		Requirements = {
			Energy = 0,
			Rebirth = 0,
			Speed = ConvertSuffix(18, "K"),  -- 18 thousand
			Strength = ConvertSuffix(18, "K"),
		},
	},
	["Carrot Bomb"] = {
		Cost = 700_000,
		DetectDuration = 3,
		Hitbox = Vector3.new(400, 400, 400),
		MaxTime = 5,
		Requirements = {
			Energy = ConvertSuffix(50, "B"),  -- 50 billion
			Rebirth = 0,
			Speed = ConvertSuffix(50, "B"),
			Strength = ConvertSuffix(50, "B"),
		},
	},

	["Dark King Final Flash"] = {
		Allignment = "Evil",
		Cost = 6000,
		Requirements = {
			Energy = ConvertSuffix(4.5, "M"),  -- 4.5 million
			Rebirth = 0,
			Speed = 0,
			Strength = 0,
		},
	},
	["Dark Pink Departure"] = {
		Allignment = "Evil",
		Cost = 100,
		Requirements = {
			Energy = ConvertSuffix(300, "M"),  -- 300 million
			Rebirth = 0,
			Speed = ConvertSuffix(300, "M"),
			Strength = ConvertSuffix(300, "M"),
		},
	},
	["Death Beam"] = {
		Allignment = "Evil",
		Cost = 25,
		Requirements = {
			Energy = ConvertSuffix(6.5, "K"),  -- 6.5 thousand
			Rebirth = 0,
			Speed = 0,
			Strength = 0,
		},
	},
	["Destruction Orb"] = {
		Allignment = "Evil",
		Cost = 5000,
		DetectDuration = 1,
		Hitbox = Vector3.new(90, 90, 90),
		MaxTime = 2,
		Requirements = {
			Energy = ConvertSuffix(20, "M"),  -- 20 million
			Rebirth = 0,
			Speed = 0,
			Strength = 0,
		},
	},


	["Emperor's Death Beam"] = {
		Allignment = "Evil",
		Cost = 2500,
		Requirements = {
			Energy = ConvertSuffix(12, "M"),  -- 12 million
			Rebirth = 0,
			Speed = 0,
			Strength = 0,
		},
	},
	["Energy Blast"] = {
		Cost = 10,
		Requirements = {
			Energy = 0,
			Rebirth = 0,
			Speed = 0,
			Strength = 0,
		},
	},
	["Energy Volley"] = {
		Cost = 40,
		Requirements = {
			Energy = ConvertSuffix(4, "K"),  -- 4 thousand
			Rebirth = 0,
			Speed = 0,
			Strength = 0,
		},
	},

	["Final Flash"] = {
		Cost = 120,
		Requirements = {
			Energy = ConvertSuffix(28, "K"),  -- 28 thousand
			Rebirth = 0,
			Speed = 0,
			Strength = 0,
		},
	},
	["Final Kamehameha"] = {
		Allignment = "Good",
		Cost = 5000,
		Requirements = {
			Energy = ConvertSuffix(3.2, "M"),  -- 3.2 million
			Rebirth = 0,
			Speed = 0,
			Strength = 0,
		},
	},
	["Final Shine"] = {
		Cost = 280,
		Requirements = {
			Energy = ConvertSuffix(250, "K"),  -- 250 thousand
			Rebirth = 0,
			Speed = 0,
			Strength = 0,
		},
	},
	["Flash Kick"] = {
		Cost = 70,
		Requirements = {
			Energy = 0,
			Rebirth = 0,
			Speed = ConvertSuffix(500, "K"),  -- 500 thousand
			Strength = ConvertSuffix(500, "K"),
		},
	},
	["Galick Gun"] = {
		Cost = 30,
		Requirements = {
			Energy = ConvertSuffix(2.5, "K"),  -- 2.5 thousand
			Rebirth = 0,
			Speed = 0,
			Strength = 0,
		},
	},
	["Galick Kamehameha"] = {
		Cost = 650,
		Requirements = {
			Energy = ConvertSuffix(700, "K"),  -- 700 thousand
			Rebirth = 0,
			Speed = 0,
			Strength = 0,
		},
	},
	["Gamma Burst Flash"] = {
		Cost = 950,
		Requirements = {
			Energy = ConvertSuffix(900, "K"),  -- 900 thousand
			Rebirth = 0,
			Speed = 0,
			Strength = 0,
		},
	},
	["Gigantic Omegastorm"] = {
		Allignment = "Evil",
		Cost = 2100,
		Requirements = {
			Energy = ConvertSuffix(2.2, "M"),  -- 2.2 million
			Rebirth = 0,
			Speed = 0,
			Strength = 0,
		},
	},
	["God Blast"] = {
		Cost = 2500,
		Requirements = {
			Energy = ConvertSuffix(12, "M"),  -- 12 million
			Rebirth = 0,
			Speed = 0,
			Strength = 0,
		},
	},
	["God Final Flash"] = {
		Allignment = "Good",
		Cost = 6000,
		Requirements = {
			Energy = ConvertSuffix(4.5, "M"),  -- 4.5 million
			Rebirth = 0,
			Speed = 0,
			Strength = 0,
		},
	},
	["God Kamehameha"] = {
		Allignment = "Good",
		Cost = 380,
		Requirements = {
			Energy = ConvertSuffix(400, "K"),  -- 400 thousand
			Rebirth = 0,
			Speed = 0,
			Strength = 0,
		},
	},
	["God Slicer"] = {
		Allignment = "Evil",
		Cost = 8000,
		Requirements = {
			Energy = 0,
			Rebirth = 0,
			Speed = ConvertSuffix(60, "M"),  -- 60 million
			Strength = ConvertSuffix(60, "M"),
		},
	},

	["Godly Space Cutter"] = {
		Allignment = "Evil",
		Cost = 100,
		Requirements = {
			Energy = ConvertSuffix(320, "M"),  -- 320 million
			Rebirth = 0,
			Speed = ConvertSuffix(320, "M"),
			Strength = ConvertSuffix(320, "M"),
		},
	},
	["Grim Reaper’s Scythe Slash"] = {
		Cost = 30,
		Requirements = {
			Energy = ConvertSuffix(500, "M"),  -- 500 million
			Rebirth = 0,
			Speed = ConvertSuffix(500, "M"),
			Strength = ConvertSuffix(500, "M"),
		},
	},
	["High Power Rush"] = {
		Cost = 70,
		Requirements = {
			Energy = 0,
			Rebirth = 0,
			Speed = ConvertSuffix(65, "K"),  -- 65 thousand
			Strength = ConvertSuffix(65, "K"),
		},
	},
	["Hyper Galick Gun"] = {
		Cost = 180,
		Requirements = {
			Energy = ConvertSuffix(130, "K"),  -- 130 thousand
			Rebirth = 0,
			Speed = 0,
			Strength = 0,
		},
	},
	["Jack-o'-lantern Blast"] = {
		Cost = 30,
		Requirements = {
			Energy = ConvertSuffix(1, "B"),  -- 1 billion
			Rebirth = 0,
			Speed = ConvertSuffix(1, "B"),
			Strength = ConvertSuffix(1, "B"),
		},
	},

	["Kamehameha x 10"] = {
		Cost = 200,
		Requirements = {
			Energy = ConvertSuffix(160, "K"),  -- 160 thousand
			Rebirth = 0,
			Speed = 0,
			Strength = 0,
		},
	},

	["Mach Kick"] = {
		Cost = 30,
		Requirements = {
			Energy = 0,
			Rebirth = 0,
			Speed = ConvertSuffix(90, "K"),  -- 90 thousand
			Strength = ConvertSuffix(90, "K"),
		},
		Cooldown = 5
	},

	["Meteor Charge"] = {
		Cost = 40,
		Requirements = {
			Energy = 0,
			Rebirth = 0,
			Speed = ConvertSuffix(12, "K"),  -- 12 thousand
			Strength = ConvertSuffix(12, "K"),
		},
	},
	["Meteor Crash"] = {
		Cost = 30,
		Requirements = {
			Energy = 0,
			Rebirth = 0,
			Speed = ConvertSuffix(28, "K"),  -- 28 thousand
			Strength = ConvertSuffix(28, "K"),
		},
	},
	["Meteor Strike"] = {
		Cost = 70,
		Requirements = {
			Energy = 0,
			Rebirth = 0,
			Speed = ConvertSuffix(130, "K"),  -- 130 thousand
			Strength = ConvertSuffix(130, "K"),
		},
	},
	["Omega Blaster"] = {
		Allignment = "Evil",
		Cost = 1200,
		DetectDuration = 2,
		Hitbox = Vector3.new(60, 60, 60),
		MaxTime = 5,
		Requirements = {
			Energy = ConvertSuffix(1.5, "M"),  -- 1.5 million
			Rebirth = 0,
			Speed = 0,
			Strength = 0,
		},
		SizeScale = 20,
	},
	["Planet Crusher"] = {
		Allignment = "Evil",
		Cost = 3000,
		DetectDuration = 2,
		Hitbox = Vector3.new(70, 70, 70),
		MaxTime = 2,
		Requirements = {
			Energy = ConvertSuffix(8, "M"),  -- 8 million
			Rebirth = 0,
			Speed = 0,
			Strength = 0,
		},
		SizeScale = 30,
	},
	["Ray of Light"] = {
		Allignment = "Evil",
		Cost = 2500,
		Requirements = {
			Energy = ConvertSuffix(12, "M"),  -- 12 million
			Rebirth = 0,
			Speed = 0,
			Strength = 0,
		},
	},
	["Rock Impact"] = {
		Cost = 0,
		Requirements = {
			Energy = ConvertSuffix(200, "M"),  -- 200 million
			Rebirth = 0,
			Speed = ConvertSuffix(200, "M"),
			Strength = ConvertSuffix(200, "M"),
		},
	},
	["Rose Kamehameha"] = {
		Allignment = "Evil",
		Cost = 380,
		Requirements = {
			Energy = ConvertSuffix(400, "K"),  -- 400 thousand
			Rebirth = 0,
			Speed = 0,
			Strength = 0,
		},
	},

	["Soul Punisher"] = {
		Allignment = "Good",
		Cost = 5000,
		Gamepass = 9848987,
		MaxTime = 2,
		Requirements = {
			Energy = ConvertSuffix(40, "M"),  -- 40 million
			Rebirth = 0,
			Speed = 0,
			Strength = 0,
		},
	},
	["Special Beam Cannon"] = {
		Allignment = "Good",
		Cost = 50,
		Requirements = {
			Energy = ConvertSuffix(9.5, "K"),  -- 9.5 thousand
			Rebirth = 0,
			Speed = 0,
			Strength = 0,
		},
	},
	["Spectral Scream Cannon"] = {
		Cost = 30,
		Requirements = {
			Energy = ConvertSuffix(500, "M"),  -- 500 million
			Rebirth = 0,
			Speed = ConvertSuffix(500, "M"),
			Strength = ConvertSuffix(500, "M"),
		},
	},
	["Spirit Barrage"] = {
		Allignment = "Good",
		Cost = 8000,
		Requirements = {
			Energy = 0,
			Rebirth = 0,
			Speed = ConvertSuffix(60, "M"),  -- 60 million
			Strength = ConvertSuffix(60, "M"),
		},
	},
	["Spirit Bomb"] = {
		Allignment = "Good",
		Cost = 160,
		DetectDuration = 2,
		Hitbox = Vector3.new(100, 100, 100),
		MaxTime = 30,
		Requirements = {
			Energy = ConvertSuffix(45, "K"),  -- 45 thousand
			Rebirth = 0,
			Speed = 0,
			Strength = 0,
		},
		SizeScale = 15,
	},
	["Spirit Breaking Cannon"] = {
		Cost = 70,
		Requirements = {
			Energy = 0,
			Rebirth = 0,
			Speed = ConvertSuffix(200, "K"),  -- 200 thousand
			Strength = ConvertSuffix(200, "K"),
		},
	},
	["Spirit Sword Excalibur"] = {
		Allignment = "Good",
		Cost = 100,
		Requirements = {
			Energy = ConvertSuffix(300, "M"),  -- 300 million
			Rebirth = 0,
			Speed = ConvertSuffix(300, "M"),
			Strength = ConvertSuffix(300, "M"),
		},
	},
	["Spirit Sword Special"] = {
		Allignment = "Good",
		Cost = 100,
		Requirements = {
			Energy = ConvertSuffix(320, "M"),  -- 320 million
			Rebirth = 0,
			Speed = ConvertSuffix(320, "M"),
			Strength = ConvertSuffix(320, "M"),
		},
	},

	["Super Dragon Fist"] = {
		Cost = 5000,
		Requirements = {
			Energy = 0,
			Rebirth = 0,
			Speed = ConvertSuffix(50, "M"),  -- 50 million
			Strength = ConvertSuffix(50, "M"),
		},
	},
	["Super Kamehameha"] = {
		Cost = 130,
		Requirements = {
			Energy = ConvertSuffix(95, "K"),  -- 95 thousand
			Rebirth = 0,
			Speed = 0,
			Strength = 0,
		},
	},
	["Transcendent Blazer"] = {
		Allignment = "Good",
		Cost = 100,
		Requirements = {
			Energy = ConvertSuffix(350, "M"),  -- 350 million
			Rebirth = 0,
			Speed = ConvertSuffix(350, "M"),
			Strength = ConvertSuffix(350, "M"),
		},
	},

	["Ultimate Spirit Bomb"] = {
		Allignment = "Good",
		Cost = 5000,
		DetectDuration = 1,
		Hitbox = Vector3.new(90, 90, 90),
		MaxTime = 2,
		Requirements = {
			Energy = ConvertSuffix(20, "M"),  -- 20 million
			Rebirth = 0,
			Speed = 0,
			Strength = 0,
		},
	},

}