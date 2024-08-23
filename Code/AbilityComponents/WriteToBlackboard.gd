class_name WriteToBlackboard extends AbilityNode

@export var property: StringName
@export var source: DataSource

func process_ability(_delta: float) -> ARunResult:
	blackboard[property] = source.get_data(player, blackboard)
	return ARunResult.Done

func physics_process_ability(_delta: float) -> ARunResult:
	blackboard[property] = source.get_data(player, blackboard)
	return ARunResult.Done
