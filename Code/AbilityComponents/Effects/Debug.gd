class_name Debug extends AbilityNode

@export var label := ""

@export var debug_first := true
@export var debug_process := false
@export var debug_deactivate := true

func deactivate() -> void:
	if debug_deactivate:
		push_warning("%s deactivate", label)

func physics_process_ability(delta: float, first: bool) -> ARunResult:
	if debug_process or (debug_first and first):
		push_warning("%s physics_process_ability, first: %s, delta: %s" % [label, first, delta])
	return ARunResult.Wait
