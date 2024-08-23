class_name CharacterSource extends DataSource

enum What {
	Position,
}

@export var what: What

func get_data(_delta: float) -> Variant:
	match what:
		What.Position:
			return runner.character.position
	assert(false, "Invalid kind of data requested from a CharacterSource")
	return null
