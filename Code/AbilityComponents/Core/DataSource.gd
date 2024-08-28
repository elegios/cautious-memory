## Base class of data sources used to parameterize ability
## actions. Should not be used directly, only through subclasses.
class_name DataSource extends Resource

var runner: AbilityRunner
var blackboard: Dictionary

func _init() -> void:
	resource_local_to_scene = true

func setup(r: AbilityRunner, b: Dictionary) -> DataSource:
	var ret: DataSource = duplicate()
	ret.runner = r
	ret.blackboard = b
	return ret

## Encode source state (if any) in an array, to be sent to other
## clients when syncing execution status.
func save_state(_buffer: Array) -> void:
	pass

## Inverse of [method DataSource.save_state], should restore state.
func load_state(_buffer: Array, idx: int) -> int:
	return idx

func pre_first_data() -> void:
	pass

## Get the current value from the source. Make sure to only contribute
## 'delta' from one of the _process functions (physics or idle).
func get_data(_delta: float) -> Variant:
	return null
