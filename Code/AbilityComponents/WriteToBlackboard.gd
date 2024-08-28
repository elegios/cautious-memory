## Write a value (computed via a [DataSource]) to the blackboard.
class_name WriteToBlackboard extends AbilityNode

## The property to be overwritten
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

# NOTE(vipa, 2024-08-23): It's ok to pass delta from both process
# functions because this action finishes immediately, i.e., we only
# ever apply the delta once. (This also means that it's not very
# useful to have stateful sources here)
func process_ability(delta: float) -> ARunResult:
	if source:
		blackboard[property] = source.get_data(delta)
	else:
		var _existed := blackboard.erase(property)
	return ARunResult.Done

func physics_process_ability(delta: float) -> ARunResult:
	if source:
		blackboard[property] = source.get_data(delta)
	else:
		var _existed := blackboard.erase(property)
	return ARunResult.Done
