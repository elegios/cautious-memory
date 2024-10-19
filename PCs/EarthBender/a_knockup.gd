class_name Knockup extends AbilityScript

@export var duration := 0.2

@export var height : Curve
@export var max_height := 30.0

func _ability() -> AbilityNode:
	return any(
		timer(str(duration), {"curve": height, "property": "height"}),
		visual_offset("Vector2(0, -bb.height*%s)" % max_height),
		)
