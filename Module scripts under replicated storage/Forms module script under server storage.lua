local ConvertSuffix = _G.ConvertSuffix

return {
	LBLSSJ4 = {
		Gamepass = 1097286366,
		Requirements = {
			Energy = ConvertSuffix(300, "M"),  -- 300 million
			Rebirth = 0,
			Speed = ConvertSuffix(300, "M"),
			Strength = ConvertSuffix(300, "M"),
		},
		Time = "Long",
	},
	Mystic = {
		Requirements = {
			Energy = ConvertSuffix(1.2, "B"),  -- 200 million
			Rebirth = 0,
			Speed = ConvertSuffix(1.2, "B"),
			Strength = ConvertSuffix(1.2, "B"),
		},
		Time = "Long",
	},
	SSJ = {
		Requirements = {
			Energy = ConvertSuffix(6, "M"),  -- 2 million
			Rebirth = 0,
			Speed = ConvertSuffix(6, "M"),
			Strength = ConvertSuffix(6, "M"),
		},
		Time = "Short",
	},
	SSJ2 = {
		Requirements = {
			Energy = ConvertSuffix(35, "M"),  -- 10 million
			Mastery = {
				SSJ = 10,
			},
			Rebirth = 0,
			Speed = ConvertSuffix(35, "M"),
			Strength = ConvertSuffix(35, "M"),
		},
		Time = "Short",
	},
	SSJ3 = {
		Requirements = {
			Energy = ConvertSuffix(400, "M"),  -- 90 million
			Mastery = {
				SSJ2 = 10,
			},
			Rebirth = 0,
			Speed = ConvertSuffix(400, "M"),
			Strength = ConvertSuffix(400, "M"),
		},
		Time = "Long",
	},

	
	SSJG = {
		Requirements = {
			Energy = ConvertSuffix(20, "B"),  -- 1 billion
			Rebirth = 0,
			Speed = ConvertSuffix(20, "B"),
			Strength = ConvertSuffix(20, "B"),
		},
		Time = "Long",
	},
	
	Kaioken = {
		Requirements = {
			Energy = ConvertSuffix(10, "K"),  -- 1 thousand
			Rebirth = 0,
			Speed = ConvertSuffix(10, "K"),
			Strength = ConvertSuffix(10, "K"),
		},
		Time = "Short",
	},
	Ikari = {
		Gamepass = 7837022,
		Requirements = {
			Energy = ConvertSuffix(800, "M"),  -- 800 million
			Rebirth = 0,
			Speed = ConvertSuffix(800, "M"),
			Strength = ConvertSuffix(800, "M"),
		},
		Time = "Short",
	},
	
	Beast = {
		Requirements = {
			Energy = ConvertSuffix(200, "QD"),  -- 1.3 trillion
			Rebirth = 0,
			Speed = ConvertSuffix(200, "QD"),
			Strength = ConvertSuffix(200, "QD"),
		},
		Time = "Cutscene",
	},
	Blanco = {
		Gamepass = 676684901,
		Requirements = {
			Energy = ConvertSuffix(500, "QD"),  -- 500 quadrillion
			Rebirth = 0,
			Speed = ConvertSuffix(500, "QD"),
			Strength = ConvertSuffix(500, "QD"),
		},
		Time = "Cutscene",
	},
	CSSJB = {
		Gamepass = 1097286366,
		Requirements = {
			Energy = ConvertSuffix(800, "B"),  -- 800 billion
			Mastery = {
				["SSJ Blue"] = 10,
			},
			Rebirth = 0,
			Speed = ConvertSuffix(800, "B"),
			Strength = ConvertSuffix(800, "B"),
		},
		Time = "Long",
	},
	CSSJB2 = {
		Gamepass = 1097286366,
		Requirements = {
			Energy = ConvertSuffix(80, "T"),  -- 80 trillion
			Mastery = {
				SSJB2 = 10,
			},
			Rebirth = 0,
			Speed = ConvertSuffix(80, "T"),
			Strength = ConvertSuffix(80, "T"),
		},
		Time = "Long",
	},
	CSSJB3 = {
		Gamepass = 1097286366,
		Requirements = {
			Energy = ConvertSuffix(350, "QD"),  -- 350 quadrillion
			Rebirth = 0,
			Speed = ConvertSuffix(350, "QD"),
			Strength = ConvertSuffix(350, "QD"),
		},
		Time = "Long",
	},

	FSSJ = {
		Requirements = {
			Energy = ConvertSuffix(600, "K"),  -- 100 thousand
			Rebirth = 0,
			Speed = ConvertSuffix(600, "K"),
			Strength = ConvertSuffix(600, "K"),
		},
		Time = "Short",
	},
	["Divine Blue"] = {
		Allignment = "Good",
		Requirements = {
			Energy = ConvertSuffix(6, "SX"),  -- 450 trillion
			Mastery = {
				["Blue Evolution"] = 10,
				["Ultra Instinct Omen"] = 10,
			},
			Rebirth = 0,
			Speed = ConvertSuffix(6, "SX"),
			Strength = ConvertSuffix(6, "SX"),
		},
		Time = "Transform",
	},
	["Divine Rose Prominence"] = {
		Allignment = "Evil",
		Requirements = {
			Energy = ConvertSuffix(6, "SX"),  -- 450 trillion
			Mastery = {
				["Dark Rose"] = 10,
				["Ultra Instinct Omen"] = 10,
			},
			Rebirth = 0,
			Speed = ConvertSuffix(6, "SX"),
			Strength = ConvertSuffix(6, "SX"),
		},
		Time = "Transform",
	},

	["Evil SSJ"] = {
		Allignment = "Evil",
		Requirements = {
			Energy = ConvertSuffix(4, "M"),  -- 4 million
			Rebirth = 0,
			Speed = ConvertSuffix(4, "M"),
			Strength = ConvertSuffix(4, "M"),
		},
		Time = "Long",
	},
	

	LBSSJ4 = {
		Requirements = {
			Energy = ConvertSuffix(4, "QN"),  -- 100 million
			Rebirth = 0,
			Speed = ConvertSuffix(4, "QN"),
			Strength = ConvertSuffix(4, "QN"),
		},
		Time = "Long",
	},
	
	["Godly SSJ2"] = {
		Requirements = {
			Energy = ConvertSuffix(8, "M"),  -- 8 million
			Rebirth = 0,
			Speed = ConvertSuffix(8, "M"),
			Strength = ConvertSuffix(8, "M"),
		},
		Time = "Long",
	},
	

	["Jiren Ultra Instinct"] = {
		Allignment = "Evil",
		Requirements = {
			Energy = ConvertSuffix(14, "M"),  -- 14 million
			Mastery = {
				["Ultra Instinct Omen"] = 10,
			},
			Rebirth = 0,
			Speed = ConvertSuffix(14, "M"),
			Strength = ConvertSuffix(14, "M"),
		},
		Time = "Long",
	},
	["Kefla SSJ2"] = {
		Allignment = "Good",
		Requirements = {
			Energy = ConvertSuffix(3, "M"),  -- 3 million
			Rebirth = 0,
			Speed = ConvertSuffix(3, "M"),
			Strength = ConvertSuffix(3, "M"),
		},
		Time = "Long",
	},
	["LSSJ Kaioken"] = {
		Gamepass = 6950449,
		Requirements = {
			Energy = ConvertSuffix(130, "M"),  -- 130 million
			Rebirth = 0,
			Speed = ConvertSuffix(130, "M"),
			Strength = ConvertSuffix(130, "M"),
		},
		Time = "Long",
	},
	["Ultra Ego"] = {
		Allignment = "Evil",
		Requirements = {
			Energy = ConvertSuffix(35, "QD"),  -- 600 billion
			Rebirth = 0,
			Speed = ConvertSuffix(35, "QD"),
			Strength = ConvertSuffix(35, "QD"),
		},
		Time = "Long",
	},
	["Mastered Ultra Instinct"] = {
		Allignment = "Good",
		Requirements = {
			Energy = ConvertSuffix(35, "QD"),  -- 600 billion
			Mastery = {
				["Ultra Instinct Omen"] = 10,
			},
			Rebirth = 0,
			Speed = ConvertSuffix(35, "QD"),
			Strength = ConvertSuffix(35, "QD"),
		},
		Time = "Long",
	},

	["Mystic Kaioken"] = {
		Gamepass = 6950449,
		Requirements = {
			Energy = ConvertSuffix(500, "M"),  -- 500 million
			Rebirth = 0,
			Speed = ConvertSuffix(500, "M"),
			Strength = ConvertSuffix(500, "M"),
		},
		Time = "Long",
	},
	["Super Broly"] = {
		Gamepass = 7837022,
		Requirements = {
			Energy = ConvertSuffix(600, "B"),  -- 600 billion
			Rebirth = 0,
			Speed = ConvertSuffix(600, "B"),
			Strength = ConvertSuffix(600, "B"),
		},
		Time = "Long",
	},
	["SSJ Blue"] = {
		Allignment = "Good",
		Requirements = {
			Energy = ConvertSuffix(400, "B"),  -- 7 billion
			Mastery = {
				SSJG = 10,
			},
			Rebirth = 0,
			Speed = ConvertSuffix(400, "B"),
			Strength = ConvertSuffix(400, "B"),
		},
		Time = "Long",
	},
	["SSJ Kaioken"] = {
		Requirements = {
			Energy = ConvertSuffix(16, "K"),  -- 16 thousand
			Rebirth = 0,
			Speed = ConvertSuffix(16, "K"),
			Strength = ConvertSuffix(16, "K"),
		},
		Time = "Short",
	},
	["SSJ Rose"] = {
		Allignment = "Evil",
		Requirements = {
			Energy = ConvertSuffix(7, "B"),  -- 7 billion
			Mastery = {
				SSJG = 10,
			},
			Rebirth = 0,
			Speed = ConvertSuffix(7, "B"),
			Strength = ConvertSuffix(7, "B"),
		},
		Time = "Long",
	},
	["SSJ2 Kaioken"] = {
		Gamepass = 6950449,
		Requirements = {
			Energy = ConvertSuffix(8, "M"),  -- 8 million
			Rebirth = 0,
			Speed = ConvertSuffix(8, "M"),
			Strength = ConvertSuffix(8, "M"),
		},
		Time = "Short",
	},
	["True God of Creation"] = {
		Allignment = "Good",
		Gamepass = 9848987,
		Requirements = {
			Energy = ConvertSuffix(50, "QD"),  -- 50 quadrillion
			Mastery = {
				["Mastered Ultra Instinct"] = 10,
			},
			Rebirth = 0,
			Speed = ConvertSuffix(50, "QD"),
			Strength = ConvertSuffix(50, "QD"),
		},
		Time = "Long",
	},
	["True God of Destruction"] = {
		Allignment = "Evil",
		Gamepass = 9848987,
		Requirements = {
			Energy = ConvertSuffix(50, "QD"),  -- 50 quadrillion
			Mastery = {
				["Ultra Ego"] = 10,
			},
			Rebirth = 0,
			Speed = ConvertSuffix(50, "QD"),
			Strength = ConvertSuffix(50, "QD"),
		},
		Time = "Long",
	},
	["True SSJG"] = {
		Gamepass = 9848987,
		Requirements = {
			Energy = ConvertSuffix(1.2, "QN"),  -- 1.2 quintillion
			Rebirth = 0,
			Speed = ConvertSuffix(1.2, "QN"),
			Strength = ConvertSuffix(1.2, "QN"),
		},
		Time = "Transform",
	},
	
	["Ultra Instinct Omen"] = {
		Requirements = {
			Energy = ConvertSuffix(200, "T"),  -- 50 billion
			Rebirth = 0,
			Speed = ConvertSuffix(200, "T"),
			Strength = ConvertSuffix(200, "T"),
		},
		Time = "Long",
	},

	["Ego Instinct"] = {
		Requirements = {
			Energy = ConvertSuffix(350, "Sp"),  -- 600 quadrillion
			Mastery = {
				["Mastered Ultra Instinct"] = 10,
				["Ultra Ego"] = 10,
			},
			Rebirth = 0,
			Speed = ConvertSuffix(350, "Sp"),
			Strength = ConvertSuffix(350, "Sp"),
		},
		Time = "Transform",
	},
	["Dark Rose"] = {
		Allignment = "Evil",
		Requirements = {
			Energy = ConvertSuffix(6, "T"),  -- 25 billion
			Mastery = {
				["SSJ Rose"] = 10,
			},
			Rebirth = 0,
			Speed = ConvertSuffix(6, "T"),
			Strength = ConvertSuffix(6, "T"),
		},
		Time = "Long",
	},
	["Blue Evolution"] = {
		Allignment = "Good",
		Requirements = {
			Energy = ConvertSuffix(6, "T"),  -- 25 billion
			Mastery = {
				["SSJ Blue"] = 10,
			},
			Rebirth = 0,
			Speed = ConvertSuffix(6, "T"),
			Strength = ConvertSuffix(6, "T"),
		},
		Time = "Long",
	},
	LSSJ = {
		Requirements = {
			Energy = ConvertSuffix(120, "M"),  -- 40 million
			Rebirth = 0,
			Speed =  ConvertSuffix(120, "M"),
			Strength = ConvertSuffix(120, "M"),
		},
		Time = "Long",
	},
	LSSJ2 = {
		Gamepass = 6951002,
		Requirements = {
			Energy = ConvertSuffix(210, "M"),  -- 210 million
			Rebirth = 0,
			Speed = ConvertSuffix(210, "M"),
			Strength = ConvertSuffix(210, "M"),
		},
		Time = "Short",
	},
	LSSJ3 = {
		Gamepass = 6951002,
		Requirements = {
			Energy = ConvertSuffix(450, "M"),  -- 450 million
			Rebirth = 0,
			Speed = ConvertSuffix(450, "M"),
			Strength = ConvertSuffix(450, "M"),
		},
		Time = "Short",
	},
	LSSJ4 = {
		Gamepass = 6951002,
		Requirements = {
			Energy = ConvertSuffix(9, "B"),  -- 9 billion
			Rebirth = 0,
			Speed = ConvertSuffix(9, "B"),
			Strength = ConvertSuffix(9, "B"),
		},
		Time = "Long",
	},
	LSSJ5 = {
		Gamepass = 6951002,
		Requirements = {
			Energy = ConvertSuffix(40, "QD"),  -- 40 quadrillion
			Rebirth = 0,
			Speed = ConvertSuffix(40, "QD"),
			Strength = ConvertSuffix(40, "QD"),
		},
		Time = "Long",
	},

	LSSJB = {
		Gamepass = 6951002,
		Requirements = {
			Energy = ConvertSuffix(600, "B"),  -- 600 billion
			Rebirth = 0,
			Speed = ConvertSuffix(600, "B"),
			Strength = ConvertSuffix(600, "B"),
		},
		Time = "Long",
	},
}