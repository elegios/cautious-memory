## Make temporary changes to the character state.
class_name CharacterState extends AbilityNode

## Stop colliding with other units.
@export var phase_through_units: bool = false

var active: bool:
	set(value):
		if active != value:
			set_state_active(value)
		active = value

func transition(kind: TKind, _dir: TDir) -> ARunResult:
	match kind:
		TKind.Enter:
			active = true
		TKind.Exit:
			active = false
	return ARunResult.Wait

func physics_process_ability(_delta: float) -> ARunResult:
	return ARunResult.Wait

func set_state_active(target: bool) -> void:
	if phase_through_units:
		if target:
			runner.character.collision_mask &= ~1
			runner.character.collision_layer &= ~1
		else:
			runner.character.collision_mask |= 1
			runner.character.collision_layer |= 1
