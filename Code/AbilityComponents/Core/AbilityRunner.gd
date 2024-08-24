## Component that enables running abilities
class_name AbilityRunner extends MultiplayerSpawner

signal main_ability_started
signal main_ability_ended

## Automatically run the first ability on _ready(). Useful for
## projectiles and the like, less so for player characters.
@export var auto_run: bool = false

## The abilities that can be run
@export var abilities: Array[PackedScene]

## Various features that ability components may use. Unused features
## can be unset.
@export_group("Ability Features")
@export var character: CharacterBody2D
@export var nav_agent: NavigationAgent2D
@export var player_input: PlayerInput
@export var shape_cast: ShapeCast2D

## The currently running main ability, if any. Trying to run a new
## ability will soft-interrupt the current main ability, then start a
## new ability [i]if the main ability actually did interrupt[/i],
## e.g., if it used the [Cancellable] node.
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
	if auto_run:
		var _success := try_run_ability(0)

## Try to run an ability, sending a soft interrupt to the currently
## running main ability, if one exists. Fails if:
## - Not called on the server
## - The main ability did not acknowledge the interrupt
func try_run_ability(id: int) -> bool:
	if not multiplayer.is_server():
		return false

	if main_ability and main_ability.try_soft_interrupt():
		main_ability.queue_free()
		main_ability = null
	if not main_ability:
		var _abi := spawn(id)
		return true
	return false

func is_main_ability_running() -> bool:
	return main_ability and not main_ability.done

func try_soft_interrupt() -> bool:
	if main_ability:
		return not main_ability.done and main_ability.try_soft_interrupt()
	return true

func _spawn_ability(id: int) -> Node:
	var abi := abilities[id].instantiate() as AbilityNode
	var root := AbilityRoot.new()
	root.add_child(abi)
	root.setup(self, multiplayer.is_server())
	var _connected := root.ability_done.connect(_ability_done)
	main_ability = root
	return root

## NOTE(vipa, 2024-08-23): Called via signal when an owned ability
## finishes executing.
func _ability_done(abi: AbilityRoot) -> void:
	if multiplayer.is_server():
		abi.queue_free()
	if abi == main_ability:
		main_ability = null

## NOTE(vipa, 2024-08-23): Called on clients (not the server) when an
## ability has been despawned, i.e., when the servere thinks it's
## finished executing.
func _ability_despawned(node: Node) -> void:
	var abi := node as AbilityRoot
	if abi:
		abi.hard_interrupt()
	if abi == main_ability:
		main_ability = null
