class_name AttackNoMissile extends PlayerAbilityScript

@export var animation := AnimatedUnit.A.Slash

## How long is the attack animation? Changes animation length if
## present.
@export var attack_duration : float

## How long from the beginning of the animation should the damage
## happen?
@export var attack_point : float

## Amount by which health should change. [i]Negative[/i] if damage.
@export var health_delta : float

@export_flags_2d_physics var unit_filter : int

@export var max_range := 50.0

func _ability() -> AbilityNode:
	var animation_config := {
		"direction": "bb.target_unit.position - character.position",
		"duration": str(attack_duration),
	}
	return cancellable(
		all(
			play_animation(animation, animation_config),
			seq(
				timer(str(attack_point)),
				alter_health(str(health_delta), {"target": "bb.target_unit"})
				),
			)
		)

func _description() -> String:
	return "Attack (%s damage)" % (-health_delta)

func _can_target_point() -> bool:
	return false

func _unit_filter() -> int:
	return unit_filter

func _max_range() -> float:
	return max_range
