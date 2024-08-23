class_name AbilityRoot extends MultiplayerSynchronizer

signal ability_done

var child: AbilityNode

var done: bool = false

var blackboard: Dictionary = {}
var player: Player

func _ready() -> void:
	replication_config = replication_config.duplicate()
	if player != null:
		return
	player = self.get_parent() as Player
	assert(player != null, "AbilityRoot should be the direct child of a Player")
	assert(get_child_count() == 1, "AbilityRoot should have exactly one child")
	child = get_child(0) as AbilityNode
	assert(child != null, "AbilityRoot child should be a sub-class of AbilityNode")
	register_prop(self, "done")
	child.register_properties(self)
	child.setup(player, blackboard)

func try_input_interrupt() -> bool:
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
			ability_done.emit()

func _physics_process(delta: float) -> void:
	if done:
		return
	match child.physics_process_ability(delta):
		AbilityNode.ARunResult.Wait:
			pass
		AbilityNode.ARunResult.Done:
			done = true
			ability_done.emit()

func register_prop(node: Node, property: String, mode: SceneReplicationConfig.ReplicationMode = SceneReplicationConfig.ReplicationMode.REPLICATION_MODE_ALWAYS) -> void:
	if not multiplayer.is_server():
		return
	var prop := NodePath(get_path_to(node).get_concatenated_names() + ":" + property)
	replication_config.add_property(prop)
	replication_config.property_set_replication_mode(prop, mode)
