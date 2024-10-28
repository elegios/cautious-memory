class_name AbilityRoot extends Node

signal ability_done(root: AbilityRoot)

var child: AbilityNode

var done: bool = false
var started: bool = false

var elapsed: float = 0.0
@export var time_between_syncs: float = 0.1

var blackboard: Blackboard

func setup(runner: AbilityRunner, initial_blackboard: Blackboard) -> void:
	blackboard = initial_blackboard
	child = get_child(0) as AbilityNode
	assert(child != null, "AbilityRoot child should be a sub-class of AbilityNode")
	child.setup(runner, blackboard)

func try_interrupt(kind: AbilityNode.AInterruptKind) -> bool:
	if done:
		return true
	done = AbilityNode.AInterruptResult.Interrupted == child.interrupt(kind)
	if done:
		var _ignore := child.transition(AbilityNode.TKind.Exit, AbilityNode.TDir.Forward)
		ability_done.emit(self)
	return done

func try_soft_interrupt() -> bool:
	return try_interrupt(AbilityNode.AInterruptKind.Soft)

func try_counter_interrupt() -> bool:
	return try_interrupt(AbilityNode.AInterruptKind.Counter)

func hard_interrupt() -> void:
	var _ignore := try_interrupt(AbilityNode.AInterruptKind.Hard)

func fast_forward() -> void:
	if not started:
		var _ignore := child.transition(AbilityNode.TKind.Skip, AbilityNode.TDir.Forward)
	elif not done:
		var _ignore := child.transition(AbilityNode.TKind.Exit, AbilityNode.TDir.Forward)

func _physics_process(delta: float) -> void:
	if multiplayer.is_server():
		elapsed += delta
		if elapsed >= time_between_syncs:
			elapsed = 0
			init_sync()
	if not started:
		match child.transition(AbilityNode.TKind.Enter, AbilityNode.TDir.Forward):
			AbilityNode.ARunResult.Wait:
				started = true
			AbilityNode.ARunResult.Done, AbilityNode.ARunResult.Error:
				done = true
				var _ignore := child.transition(AbilityNode.TKind.Exit, AbilityNode.TDir.Forward)
				ability_done.emit(self)
	if done:
		return
	match child.physics_process_ability(delta):
		AbilityNode.ARunResult.Wait:
			pass
		AbilityNode.ARunResult.Done, AbilityNode.ARunResult.Error:
			done = true
			var _ignore := child.transition(AbilityNode.TKind.Exit, AbilityNode.TDir.Forward)
			ability_done.emit(self)

func init_sync() -> void:
	var state: Array = [started, done]
	blackboard.save_state(state)
	child.save_state(state)
	rpc_load_state.rpc(state)

@rpc("unreliable_ordered", "authority", "call_remote", 1)
func rpc_load_state(state: Array) -> void:
	var idx := blackboard.load_state(state, 2)

	# NOTE(vipa, 2024-10-28): Cross the "started" boundry only
	if not started and state[0] and not state[1]:
		var _ignore := child.transition(AbilityNode.TKind.Enter, AbilityNode.TDir.Forward)
	elif started and not state[0]:
		var _ignore := child.transition(AbilityNode.TKind.Exit, AbilityNode.TDir.Backward)
	# NOTE(vipa, 2024-10-28): Cross the "done" boundry only
	elif not done and state[1]:
		var _ignore := child.transition(AbilityNode.TKind.Exit, AbilityNode.TDir.Forward)
	elif done and state[0] and not state[1]:
		var _ignore := child.transition(AbilityNode.TKind.Enter, AbilityNode.TDir.Backward)
	# NOTE(vipa, 2024-10-28): Cross both boundries at once
	elif not started and state[1]:
		var _ignore := child.transition(AbilityNode.TKind.Skip, AbilityNode.TDir.Forward)
	elif done and not state[0]:
		var _ignore := child.transition(AbilityNode.TKind.Skip, AbilityNode.TDir.Backward)

	started = state[0]
	done = state[1]
	idx = child.load_state(state, idx)
	if idx != state.size():
		push_error("Failed to use up all state in ability synchronization")
