## Works like [AbilitySeq] but additionally makes temporary changes to
## the players state while executing.
class_name PlayerState extends AbilityNode

## Stop colliding with other units.
@export var phase_through_units: bool = false

# TODO(vipa, 2024-08-21): Make this synced, and make `set_state_active` into a setter
var active: bool = false

func process_ability(delta: float) -> ARunResult:
	if not active:
		set_state_active(true)
	var res := super(delta)
	if res == ARunResult.Done:
		set_state_active(false)
	return res

func physics_process_ability(delta: float) -> ARunResult:
	if not active:
		set_state_active(true)
	var res := super(delta)
	if res == ARunResult.Done:
		set_state_active(false)
	return res

func interrupt(kind: AInterruptKind) -> AInterruptResult:
	var res := super(kind)
	if res == AInterruptResult.Interrupted:
		set_state_active(false)
	return res

func set_state_active(target: bool) -> void:
	if phase_through_units:
		if target:
			player.collision_mask &= ~1
			player.collision_layer &= ~1
		else:
			player.collision_mask |= 1
			player.collision_layer |= 1
	active = target
