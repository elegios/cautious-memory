## Make temporary changes to the character state.
class_name CharacterState extends AbilityNode

## Stop colliding with other units.
@export var phase_through_units: bool = false

var active: bool:
	set(value):
		if active != value:
			set_state_active(value)
		active = value

func sync_lost() -> void:
	active = false
	super()

func sync_gained() -> void:
	active = true
	super()

func physics_process_ability(_delta: float) -> ARunResult:
	active = true
	return ARunResult.Wait

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
