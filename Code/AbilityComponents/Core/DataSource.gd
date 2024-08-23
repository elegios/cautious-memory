## Base class of data sources used to parameterize ability
## actions. Should not be used directly, only through subclasses.
class_name DataSource extends Resource

var runner: AbilityRunner
var blackboard: Dictionary

func setup(r: AbilityRunner, b: Dictionary) -> void:
	runner = r
	blackboard = b

## Register properties that need to be synced for this source
func register_properties(_node: Node, _property: String, _root: AbilityRoot) -> void:
	pass

## Get the current value from the source. Make sure to only contribute
## 'delta' from one of the _process functions (physics or idle).
func get_data(_delta: float) -> Variant:
	return null
