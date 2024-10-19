class_name MoveSword extends AbilityScript

@export var speed : float

@export var health_delta : float

@export var hit_box : Shape2D

@export_flags_2d_physics var hit_mask : int

func _ability() -> AbilityNode:
	var cast_config := {
		"additional_ignore": "bb.m_spawner",
		"collision_mask": hit_mask,
		"continuous": true,
		"collider": "hit_unit",
	}
	return seq(
		rotate("bb.target_point"),
		any(
			move("bb.target_point", {"speed": speed, "what": MoveCharacter.What.Point}),
			shapecast(hit_box, cast_config,
				alter_health(str(health_delta), {"target": "bb.hit_unit"}))
			),
		rotate("PI/2"),
		)
