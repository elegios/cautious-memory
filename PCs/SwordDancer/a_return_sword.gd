class_name ReturnSword extends AbilityScript

@export var speed : float

@export var health_delta : float

@export var hit_box : Shape2D

@export_flags_2d_physics var hit_mask : int

func _description() -> String:
	return "Return the sword if it's thrown, otherwise parry one attack."

func _is_main() -> bool:
	return false

func _cancel_move() -> bool:
	return false

func _ability() -> AbilityNode:
	var cast_config := {
		"additional_ignore": "bb.m_spawner",
		"collision_mask": hit_mask,
		"continuous": true,
		"collider": "hit_unit",
	}
	return seq(
		any(
			move("bb.m_spawner.position", {"speed": speed, "what": MoveCharacter.What.Point}),
			shapecast(hit_box, cast_config,
				alter_health(str(health_delta), {"target": "bb.hit_unit"})),
			rotate("bb.m_spawner.position", {"continuous": true}),
			),
		destroy_self(),
		)
