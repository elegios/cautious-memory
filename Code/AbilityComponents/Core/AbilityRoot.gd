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
		child.deactivate()
		ability_done.emit(self)
	return done

func try_soft_interrupt() -> bool:
	return try_interrupt(AbilityNode.AInterruptKind.Soft)

func try_counter_interrupt() -> bool:
	return try_interrupt(AbilityNode.AInterruptKind.Counter)

func hard_interrupt() -> void:
	var _ignore := try_interrupt(AbilityNode.AInterruptKind.Hard)

func fast_forward() -> void:
	if started and not done:
		child.deactivate()
		done = true

func _physics_process(delta: float) -> void:
	if multiplayer.is_server():
		elapsed += delta
		if elapsed >= time_between_syncs:
			elapsed = 0
			init_sync()
	if done:
		return
	match child.physics_process_ability(delta, not started):
		AbilityNode.ARunResult.Wait:
			started = true
		AbilityNode.ARunResult.Done, AbilityNode.ARunResult.Error:
			child.deactivate()
			done = true
			ability_done.emit(self)

func init_sync() -> void:
	var state: Array = [started, done]
	blackboard.save_state(state)
	if started and not done:
		child.save_state(state)
	rpc_load_state.rpc(state)

@rpc("unreliable_ordered", "authority", "call_remote", 1)
func rpc_load_state(state: Array) -> void:
	var idx := blackboard.load_state(state, 2)

	var was_active := started and not done
	started = state[0]
	done = state[1]
	if started and not done:
		idx = child.load_state(state, idx, was_active)
	elif was_active:
		child.deactivate()
	if idx != state.size():
		push_error("Failed to use up all state in ability synchronization")
