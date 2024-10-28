class_name ThrowSword extends PlayerAbilityScript

@export var max_range : float

@export var sword : PackedScene
@export var move_sword : AbilityScript

func _max_range() -> float:
	return max_range

func _walk_in_range() -> bool:
	return false

func _is_main() -> bool:
	return false

func _cancel_move() -> bool:
	return false

func _description() -> String:
	return "Throw (or reposition) sword."

func _ability() -> AbilityNode:
	return seq(
		cond("not bb.m_sword",
			spawn_unit(sword, "character.position", {"unit_property": "m_sword"})
			),
		run_ability(move_sword, {"target": "bb.m_sword", "copy_blackboard": true}),
		)
