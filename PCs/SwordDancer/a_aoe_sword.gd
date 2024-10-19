class_name AOESword extends AbilityScript

@export var health_delta : float

@export var hit_duration := 0.1
@export var interval := 1.0

@export var hit_box : Shape2D

@export_flags_2d_physics var hit_mask : int

@export var effect : PackedScene

func _ability() -> AbilityNode:
	var cast_config := {
		"continuous": true,
		"collider": "hit_unit",
		"collision_mask": hit_mask,
		"additional_ignore": "bb.m_spawner",
	}
	return seq(
		create_effect(effect) if effect else null,
		any(
			shapecast(hit_box, cast_config,
				alter_health(str(health_delta), {"target": "bb.hit_unit"})),
			timer(str(hit_duration)),
			),
		timer(str(interval)),
		)
