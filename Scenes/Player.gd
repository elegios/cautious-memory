class_name Player extends CharacterBody2D

@export var movement_speed: float = 50.0

@export var abilities: Array[PackedScene]

@onready var agent: NavigationAgent2D = %NavAgent
@onready var animation: AnimatedSprite2D = %Animation
@onready var camera: Camera2D = %Camera
@onready var spawner: MultiplayerSpawner = %Spawner

var controller: int

var mouse_point: Vector2

var running_ability: AbilityRoot
var pathing: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawner.spawn_function = spawn_ability
	var _ignore := spawner.despawned.connect(despawn_ability)
	animation.play()
	if controller == multiplayer.get_unique_id():
		camera.enabled = true

func _unhandled_input(e: InputEvent) -> void:
	if multiplayer.get_unique_id() != controller:
		return

	if e.is_action_pressed("Action 1"):
		rpc_try_action.rpc_id(1, 0)

	var mouse := e as InputEventMouseButton
	if mouse and mouse.is_action_pressed("Move"):
		rpc_move_input.rpc(get_viewport_transform().inverse() * mouse.position)

func _physics_process(_delta: float) -> void:
	if controller == multiplayer.get_unique_id():
		rpc_update_mouse.rpc(get_viewport_transform().inverse() * get_viewport().get_mouse_position())

	if running_ability and not running_ability.done:
		return

	if not pathing or agent.is_navigation_finished():
		if animation.is_playing():
			animation.frame = 0
			animation.pause()
		return

	velocity = global_position.direction_to(agent.get_next_path_position()) * movement_speed
	if 0 <= velocity.x and 0 <= velocity.y:
		animation.animation = "walk-rd"
	elif velocity.x < 0 and 0 <= velocity.y:
		animation.animation = "walk-ld"
	elif 0 <= velocity.x and velocity.y < 0:
		animation.animation = "walk-ru"
	elif velocity.x < 0 and velocity.y < 0:
		animation.animation = "walk-lu"
	if not animation.is_playing():
		animation.play()
	var _hit := move_and_slide()

@rpc("unreliable_ordered", "any_peer", "call_local", 1)
func rpc_move_input(to : Vector2) -> void:
	if multiplayer.get_remote_sender_id() != controller:
		push_error("Got rpc_move_input from incorrect client")
		return
	pathing = true
	agent.target_position = to

@rpc("unreliable_ordered", "any_peer", "call_local", 2)
func rpc_update_mouse(to: Vector2) -> void:
	if multiplayer.get_remote_sender_id() != controller:
		push_error("Got rpc_update_mouse from incorrect client")
		return
	mouse_point = to

func _ability_done() -> void:
	if multiplayer.is_server():
		running_ability.queue_free()
		running_ability = null

@rpc("reliable", "any_peer", "call_local")
func rpc_try_action(id: int) -> void:
	if not multiplayer.get_remote_sender_id() == controller:
		return
	if running_ability and not running_ability.done:
		# TODO(vipa, 2024-08-20): This is a likely source of desyncs
		if running_ability.try_input_interrupt():
			running_ability.queue_free()
			running_ability = null
	if not running_ability:
		running_ability = spawner.spawn(id) as AbilityRoot

func spawn_ability(id: int) -> Node:
	pathing = false
	var node := abilities[id].instantiate()
	var abi := node as AbilityRoot
	assert(abi != null, "The abilities property should only contain scenes with AbilityRoot as the root node")
	running_ability = abi
	var _ignore := running_ability.ability_done.connect(_ability_done)
	return abi

func despawn_ability(node: Node) -> void:
	var abi := node as AbilityRoot
	if abi:
		abi.hard_interrupt()
	if node == running_ability:
		running_ability = null
