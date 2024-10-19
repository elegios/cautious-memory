class_name FireArrow extends MobAbilityScript

@export var animation_length : float

@export var attack_point : float

@export var extra_wait : float

@export var missile : PackedScene

@export var move_missile : AbilityScript

func _ability() -> AbilityNode:
	var anim_config := {
		"direction": "bb.direction",
		"duration": animation_length,
	}
	return seq(
		write("direction", "character.position.direction_to(bb.m_target.position)"),
		all(
			seq(
				timer(str(attack_point)),
				spawn_unit(missile, "character.position", {"unit_property": "arrow"}),
				run_ability(move_missile, {"target": "bb.arrow", "copy_blackboard": true})
				),
			seq(
				play_animation(AnimatedUnit.A.Slash, anim_config),
				timer(str(extra_wait)),
				)
			),
		)
