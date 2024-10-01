class_name Player extends CharacterBody2D

@export var movement_speed: float = 50.0

@onready var agent: NavigationAgent2D = %NavAgent
@onready var animation: AnimatedUnit = %Animation
@onready var camera: Camera2D = %Camera
@onready var input: PlayerInput = %PlayerInput
@onready var runner: AbilityRunner = %AbilityRunner

var controller: int:
	set(value):
		if input:
			input.controller = value
		if camera and value == multiplayer.get_unique_id():
			camera.enabled = true
		controller = value

var pathing: bool = false:
	set(value):
		if animation:
			animation.unit_animation = AnimatedUnit.A.Walk if value else AnimatedUnit.A.Idle
		pathing = value

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if controller == multiplayer.get_unique_id():
		camera.enabled = true
	input.controller = controller

func _physics_process(_delta: float) -> void:
	if runner.is_main_ability_running():
		return

	if agent.is_navigation_finished():
		pathing = false

	if not pathing:
		return

	velocity = global_position.direction_to(agent.get_next_path_position()) * movement_speed
	if 0 <= velocity.x and 0 <= velocity.y:
		animation.unit_direction = AnimatedUnit.Dir.SE
	elif velocity.x < 0 and 0 <= velocity.y:
		animation.unit_direction = AnimatedUnit.Dir.SW
	elif 0 <= velocity.x and velocity.y < 0:
		animation.unit_direction = AnimatedUnit.Dir.NE
	elif velocity.x < 0 and velocity.y < 0:
		animation.unit_direction = AnimatedUnit.Dir.NW
	var _hit := move_and_slide()

func cancel_move() -> void:
	pathing = false

func _move_command_given(target: Vector2) -> void:
	agent.target_position = target
	pathing = true

	var _ignore := runner.try_soft_interrupt()
