class_name Debug extends AbilityNode

@export var debug_transition := true
@export var debug_process := true

func transition(kind: TKind, dir: TDir) -> ARunResult:
	if debug_transition:
		push_warning("transition, kind: %s, dir: %s" % [TKind.find_key(kind), TDir.find_key(dir)])
	return ARunResult.Wait

func physics_process_ability(delta: float) -> ARunResult:
	if debug_process:
		push_warning("physics_process_ability, delta: %s" % delta)
	return ARunResult.Wait
