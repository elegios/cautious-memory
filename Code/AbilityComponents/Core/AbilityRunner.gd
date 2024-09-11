## Component that enables running abilities
class_name AbilityRunner extends MultiplayerSpawner

signal main_ability_started
signal main_ability_ended

## Ability to automatically run (as main ability) whenever no main
## ability is running.
@export var auto_run: PackedScene

## Various features that ability components may use. Unused features
## can be unset.
@export_group("Ability Features")
@export var character: CharacterBody2D
@export var nav_agent: NavigationAgent2D
@export var player_input: PlayerInput
@export var shape_cast: ShapeCast2D

var unit_spawner: UnitSpawner
var unit_local: Blackboard

## The currently running main ability, if any. Trying to run a new
## main ability will soft-interrupt the current main ability, then
## start a new ability [i]if the main ability actually did
## interrupt[/i], e.g., if it used the [Cancellable] node.
var main_ability: AbilityRoot:
	set(value):
		if not main_ability and value:
			main_ability_started.emit()
		elif main_ability and not value:
			main_ability_ended.emit()
		main_ability = value

func _ready() -> void:
	var _connected := despawned.connect(_ability_despawned)
	spawn_function = _spawn_ability
	maybe_autorun.call_deferred()
	unit_spawner = get_tree().get_first_node_in_group(&"spawners")
	if not unit_spawner:
		push_warning("No spawner found, abilities cannot spawn things or refer to other units")
	unit_local = Blackboard.new(unit_spawner)

## Attempt to run an arbitrary ability. Note that [param interrupt] is
## only relevant when the ability is a main ability, and that if it is
## it will only start if the current main ability acknowledges that
## interrupt.
func try_run_custom_ability(config: Dictionary, interrupt: AbilityNode.AInterruptKind = AbilityNode.AInterruptKind.Counter) -> bool:
	var is_main: bool = config.get(&"is_main", true)
	if main_ability and not main_ability.done and is_main:
		if not main_ability.try_interrupt(interrupt):
			return false

	var _ignore := spawn(config)
	return true

func is_main_ability_running() -> bool:
	return main_ability and not main_ability.done

func try_soft_interrupt() -> bool:
	if main_ability:
		return main_ability.done or main_ability.try_soft_interrupt()
	return true

func _spawn_ability(config: Dictionary) -> Node:
	var path: String = config[&"path"]
	var is_main: bool = config.get(&"is_main", true)
	var initial_blackboard_state: Array = config.get(&"blackboard", [])

	var bb: Blackboard = Blackboard.new(unit_spawner)
	if initial_blackboard_state:
		var _ignore := bb.load_state(initial_blackboard_state, 0)
	bb.merge(unit_local)

	var ps: PackedScene = ResourceLoader.load(path)
	var abi := ps.instantiate() as AbilityNode

	var root := AbilityRoot.new()
	root.add_child(abi)
	root.setup(self, bb)

	var _connected := root.ability_done.connect(_ability_done)
	if is_main:
		main_ability = root
	return root

## NOTE(vipa, 2024-08-23): Called via signal when an owned ability
## finishes executing.
func _ability_done(abi: AbilityRoot) -> void:
	if multiplayer.is_server():
		unit_local.merge_m(abi.blackboard)
		abi.queue_free()
	if abi == main_ability:
		main_ability = null
	maybe_autorun.call_deferred()

func maybe_autorun() -> void:
	if not multiplayer or not multiplayer.is_server():
		return
	if not main_ability and auto_run:
		var _success := try_run_custom_ability({&"path": auto_run.resource_path})

## NOTE(vipa, 2024-08-23): Called on clients (not the server) when an
## ability has been despawned, i.e., when the server thinks it's
## finished executing.
func _ability_despawned(node: Node) -> void:
	var abi := node as AbilityRoot
	if abi:
		abi.hard_interrupt()
	if abi == main_ability:
		main_ability = null
