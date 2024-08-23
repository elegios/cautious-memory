class_name InputSource extends DataSource

enum What {
	Mouse,
}

@export var what: What

func get_data(_delta: float) -> Variant:
	match what:
		What.Mouse:
			return runner.player_input.mouse_position
	assert(false, "Invalid kind of data requested from an InputSource")
	return null
