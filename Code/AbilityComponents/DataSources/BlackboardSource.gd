## Read data from the ability-local blackboard.
class_name BlackboardSource extends DataSource

## The property to read from the blackboard.
@export var property: StringName
## Whether to allow absent properties. If true, an absent property
## will act as though 'null' was written to it.
@export var allow_absent: bool = false

func get_data(_delta: float) -> Variant:
	return blackboard.bget(property, allow_absent)
