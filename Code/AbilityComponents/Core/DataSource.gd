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

## Register properties that need to be synced for this source.
func register_properties(_node: Node, _property: String, _root: AbilityRoot) -> void:
	pass

## Duplicate self if there is mutable state, i.e., if [get_data)
func maybe_duplicate() -> DataSource:
	return self


## Get the current value from the source. Make sure to only contribute
## 'delta' from one of the _process functions (physics or idle).
func get_data(_delta: float) -> Variant:
	return null
