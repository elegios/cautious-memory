class_name Knockback extends AbilityScript

@export var duration := 0.2

@export var speed_factor : Curve

func _ability() -> AbilityNode:
	return any(
		timer(str(duration), {"curve": speed_factor, "property": "speed_factor"}),
		move("bb.knockback_direction", {"speed": "bb.knockback_speed * bb.speed_factor"}),
		)
