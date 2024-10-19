class_name MoveArrow extends AbilityScript

@export var speed := 94.0*4

@export var health_delta := -1.0

@export var hitbox : Shape2D
@export_flags_2d_physics var mask : int
@export_flags_2d_physics var wall_mask : int

@export var lifetime := 1.0

func _ability() -> AbilityNode:
	var cast_config := {
		"additional_ignore": "bb.m_spawner",
		"collision_mask": mask,
		"collider": "hit_unit",
	}
	var wall_config := {
		"collision_mask": wall_mask,
	}
	return seq(
		rotate("bb.direction.angle()"),
		any(
			move("bb.direction", {"speed": speed}),
			shapecast(hitbox, cast_config,
				alter_health(str(health_delta), {"target": "bb.hit_unit"}),
				),
			timer(str(lifetime)),
			shapecast(hitbox, wall_config)
			),
		destroy_self(),
		)
