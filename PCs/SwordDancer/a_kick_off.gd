class_name KickOff extends PlayerAbilityScript

@export var shape: Shape2D

@export var jump_distance: float
@export var jump_duration: float

@export var sit_duration: float

@export_flags_2d_physics var collision_mask: int

@export var knockback: AbilityScript

func _max_range() -> float:
	return jump_distance

func _walk_in_range() -> bool:
	return false

func _description() -> String:
	return "Jump in a direction (range: %s). If a unit is hit, land for %ss, then repeat once." % [jump_distance, sit_duration]

func _ability() -> AbilityNode:
	var speed := str(jump_distance / jump_duration)
	var cast_config := {
		"collision_mask": collision_mask,
		"collider": "hit_unit",
	}
	var jump_config := {
		"direction": "bb.direction",
		"duration": str(jump_duration),
	}
	var phase_config := {
		"phase_through_units": true,
	}
	var knockback_config := {
		"target": "bb.hit_unit",
		"copy_blackboard": true,
	}
	return seq(
		write(&"direction", "character.position.direction_to(bb.target_point)"),
		any(
			move("bb.direction", {"speed": speed}),
			shapecast(shape, cast_config),
			play_animation(AnimatedUnit.A.Jump, jump_config),
			character_state(phase_config),
			),
		if_once("bb.hit_unit",
			write(&"knockback_direction", "bb.direction"),
			write(&"knockback_speed", speed),
			run_ability(knockback, knockback_config),
			any(
				timer(str(sit_duration)),
				teleport("bb.hit_unit.position", {"continuous": true}),
				character_state(phase_config),
				),
			write(&"direction", "character.position.direction_to(mouse)"),
			write(&"knockback_direction", "-bb.direction"),
			run_ability(knockback, knockback_config),
			any(
				move("bb.direction", {"speed": speed}),
				play_animation(AnimatedUnit.A.Jump, jump_config),
				character_state(phase_config),
				),
			),
		)
