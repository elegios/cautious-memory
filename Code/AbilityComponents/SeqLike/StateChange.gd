## Works like [AbilitySeq] but additionally makes temporary changes to
## the players state while executing.
class_name PlayerState extends AbilitySeq

## Stop colliding with other units. Requires a CharacterBody2D.
@export var phase_through_units: bool = false

var active: bool:
	set(value):
		if active != value:
			set_state_active(value)
		active = value

func register_properties(root: AbilityRoot) -> void:
	root.register_prop(self, "active")

func process_ability(delta: float) -> ARunResult:
	active = true
	var res := super(delta)
	if res == ARunResult.Done:
		active = false
	return res

func physics_process_ability(delta: float) -> ARunResult:
	active = true
	var res := super(delta)
	if res == ARunResult.Done:
		active = false
	return res

func interrupt(kind: AInterruptKind) -> AInterruptResult:
	var res := super(kind)
	if res == AInterruptResult.Interrupted:
		active = false
	return res

func set_state_active(target: bool) -> void:
	if phase_through_units:
		if target:
			runner.character.collision_mask &= ~1
			runner.character.collision_layer &= ~1
		else:
			runner.character.collision_mask |= 1
			runner.character.collision_layer |= 1
