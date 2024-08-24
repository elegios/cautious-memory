## Read data from the ability-local blackboard.
class_name BlackboardSource extends DataSource

## The property to read from the blackboard.
@export var property: StringName
## Whether to allow absent properties. If true, an absent property
## will act as though 'null' was written to it.
@export var allow_absent: bool = false

func get_data(_delta: float) -> Variant:
	if not allow_absent and not blackboard.has(property):
		push_error("Missing blackboard key: " + property)
	return blackboard.get(property, null)
