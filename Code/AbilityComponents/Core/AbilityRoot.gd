class_name AbilityRoot extends MultiplayerSynchronizer

signal ability_done(root: AbilityRoot)

var child: AbilityNode

var done: bool = false

func setup(runner: AbilityRunner, blackboard: Dictionary, register_properties: bool) -> void:
	replication_config = SceneReplicationConfig.new()
	root_path = ^"."
	child = get_child(0) as AbilityNode
	assert(child != null, "AbilityRoot child should be a sub-class of AbilityNode")
	if register_properties:
		register_prop(self, "done")
	child.setup(runner, self, blackboard, register_properties)

func try_soft_interrupt() -> bool:
	return AbilityNode.AInterruptResult.Interrupted == child.interrupt(AbilityNode.AInterruptKind.Soft)

func hard_interrupt() -> void:
	var _ignore := child.interrupt(AbilityNode.AInterruptKind.Hard)

func _process(delta: float) -> void:
	if done:
		return
	match child.process_ability(delta):
		AbilityNode.ARunResult.Wait:
			pass
		AbilityNode.ARunResult.Done:
			done = true
			ability_done.emit(self)

func _physics_process(delta: float) -> void:
	if done:
		return
	match child.physics_process_ability(delta):
		AbilityNode.ARunResult.Wait:
			pass
		AbilityNode.ARunResult.Done:
			done = true
			ability_done.emit(self)

func register_prop(node: Node, property: String, mode: SceneReplicationConfig.ReplicationMode = SceneReplicationConfig.ReplicationMode.REPLICATION_MODE_ALWAYS) -> void:
	var prop := NodePath(get_path_to(node).get_concatenated_names() + ":" + property)
	replication_config.add_property(prop)
	replication_config.property_set_replication_mode(prop, mode)
