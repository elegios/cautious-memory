class_name PlayerSource extends DataSource

enum What {
	Mouse,
	Position,
}

@export var what: What

func get_data(player: Player, _blackboard: Dictionary) -> Variant:
	match what:
		What.Mouse:
			return player.mouse_point
		What.Position:
			return player.position
	assert(false, "Invalid kind of data requested from a PlayerSource")
	return null
