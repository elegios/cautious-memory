## Write a value (computed via a [DataSource]) to the blackboard.
class_name WriteToBlackboard extends AbilityNode

## The property to be overwritten. If the property is prefixed by
## [code]m_[/code], then it will be persisted on the unit between
## ability runs. Note that [code]m_[/code] properties are snapshotted
## when an ability starts, and whatever values are set when the
## ability finishes are copied back to the unit.
##
## Notably this means that clearing a [code]m_[/code] property will
## not remove it from persisted storage, and it's very much possible
## to get data races with multiple abilities reading and writing such
## properties.
@export var property: StringName

## The value to write. Will clear the property if absent.
@export var source: DataSource

func setup(a: AbilityRunner, b: Dictionary) -> void:
	if source:
		source = source.setup(a, b)
	super(a, b)

func save_state(buffer: Array) -> void:
	if source:
		source.save_state(buffer)

func load_state(buffer: Array, idx: int) -> int:
	if source:
		idx = source.load_state(buffer, idx)
	return idx

func pre_first_process() -> void:
	if source:
		source.pre_first_data()

func physics_process_ability(delta: float) -> ARunResult:
	if source:
		blackboard[property] = source.get_data(delta)
	else:
		var _existed := blackboard.erase(property)
	return ARunResult.Done
