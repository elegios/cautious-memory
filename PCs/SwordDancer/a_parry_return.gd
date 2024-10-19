class_name ParryReturn extends PlayerAbilityScript

@export var parry_duration : float

@export var return_ability : AbilityScript

func _ability() -> AbilityNode:
	return seq(
		if_once("not bb.m_sword",
			any(
				timer(str(parry_duration)),
				on_altered_health("0.0", {"condition": "delta < 0"}),
				)),
		if_once("bb.m_sword",
			run_ability(return_ability, {"target": "bb.m_sword"})),
		)
