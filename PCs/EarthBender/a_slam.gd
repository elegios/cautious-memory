class_name Slam extends PlayerAbilityScript

@export var max_range : float

@export var height : Curve
@export var max_height := 100.0
@export var duration := 0.5

@export var aoe : Shape2D
@export_flags_2d_physics var mask : int
@export var health_delta : float

@export var knockup : AbilityScript

func _ability() -> AbilityNode:
	var cast_config := {
		"collision_mask": mask,
		"continuous": true,
		"collider": "hit_unit",
	}
	return seq(
		write("velocity", "(bb.target_point - character.position)/%s" % duration),
		any(
			timer(str(duration), {"curve": height, "property": "height"}),
			visual_offset("Vector2(0, -bb.height*%s)" % max_height),
			move("bb.velocity"),
			play_animation(AnimatedUnit.A.Jump, {"duration": str(duration)}),
			character_state({"phase_through_units": true}),
			),
		any(
			shapecast(aoe, cast_config,
				alter_health(str(health_delta), {"target": "bb.hit_unit"}),
				run_ability(knockup, {"target": "bb.hit_unit"}),
				),
			timer("0.0"),
			),
		)

func _max_range() -> float:
	return max_range
