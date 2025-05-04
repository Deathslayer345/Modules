return {
	
	["CanMove"] = true,
	["CanRotate"] = true,
	["CanAttack"] = true,
	["FaceUnit"] = false,
	["FaceMouse"] = false,
	GettingHit = false,
	Flight = {
		IsFlying = false,
		ShiftFlying = false,

	},
	Ki = 100,
	MaxKi = 100,
	Strength = 0,
	Defense = 0,
	Energy = 0,
	Speed = 0,
	MaxEnergy = 100,
	FusionStats = {
		Strength = 0,
		Defense = 0,
		Energy = 0,
		Speed = 0
	},
	
	KeysPressed = {
		W = false,
		A = false,
		S = false,
		D = false,
		Space = false,
		LeftControl = false
	},
	MovementMode = "Idle",
	HitBy = {},
	Stuns = {},
	Debounces = {},
	Combo = {},
	Knocker = false,
	LockedOnTarget = {
		Type = "Object"
	},
	targ = {
		Type = "Object"
	},
	Charging = false,
	InSkillCreator = false,
	HitSomeone = false,
	Blocking = false,
	KiBlast = false,
	Damage = 0,
	InCombat = false,
	Form = "Base",
	SelectedForm = "Base",

}
