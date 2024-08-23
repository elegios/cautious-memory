class_name Player extends CharacterBody2D

@export var movement_speed: float = 50.0

@export var abilities: Array[PackedScene]

@onready var agent: NavigationAgent2D = %NavAgent
@onready var animation: AnimatedSprite2D = %Animation
@onready var camera: Camera2D = %Camera
@onready var input: PlayerInput = %PlayerInput
@onready var runner: AbilityRunner = %AbilityRunner

var controller: int:
	set(value):
		if input:
			input.controller = value
		controller = value

var pathing: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if controller == multiplayer.get_unique_id():
		camera.enabled = true
	input.controller = controller

func _physics_process(_delta: float) -> void:
	if runner.is_main_ability_running():
		return

	if not pathing or agent.is_navigation_finished():
		animation.animation = "idle-rd"
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
	var _hit := move_and_slide()

func _ability_started() -> void:
	print("abi start")
	pathing = false

func _move_command_given(target: Vector2) -> void:
	print("move command")
	if runner.try_soft_interrupt():
		pathing = true
		agent.target_position = target
