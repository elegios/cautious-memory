class_name WriteToBlackboard extends AbilityNode

@export var property: StringName
@export var source: DataSource

func register_properties(root: AbilityRoot) -> void:
	source.register_properties(self, "source", root)

func setup(a: AbilityRunner, r: AbilityRoot, b: Dictionary, register_props: bool) -> void:
	source.setup(a, b)
	super(a, r, b, register_props)

# NOTE(vipa, 2024-08-23): It's ok to pass delta from both process
# functions because this action finishes immediately, i.e., we only
# ever apply the delta once. (This also means that it's not very
# useful to have stateful sources here)
func process_ability(delta: float) -> ARunResult:
	blackboard[property] = source.get_data(delta)
	return ARunResult.Done

func physics_process_ability(delta: float) -> ARunResult:
	blackboard[property] = source.get_data(delta)
	return ARunResult.Done
