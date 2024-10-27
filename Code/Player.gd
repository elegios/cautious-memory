class_name Player extends CharacterBody2D

@export var movement_speed: float = 50.0

@onready var agent: NavigationAgent2D = %NavAgent
@onready var animation: AnimatedUnit = %Animation
@onready var camera_target: RemoteTransform2D = %CameraTarget
@onready var input: PlayerInput = %PlayerInput
@onready var abilities: PlayerAbilities = %PlayerAbilities
@onready var runner: AbilityRunner = %AbilityRunner

## If a move command is given towards a unit (via an ability use most
## likely), this is the id of the unit to move to. -1 if not moving
## towards a unit.
var move_to_unit: int = -1

var controller: int:
	set(value):
		if input:
			input.controller = value
		if abilities:
			abilities.controller = value
		if camera_target and value == multiplayer.get_unique_id():
			camera_target.remote_path = PlayerCamera.get_path()
		controller = value

var pathing: bool = false:
	set(value):
		if animation:
			animation.unit_animation = AnimatedUnit.A.Walk if value else AnimatedUnit.A.Idle
		pathing = value

func _ready() -> void:
	if controller == multiplayer.get_unique_id():
		camera_target.remote_path = PlayerCamera.get_path()
	input.controller = controller
	abilities.controller = controller

func _physics_process(_delta: float) -> void:
	if runner.is_main_ability_running():
		return

	if agent.is_navigation_finished():
		pathing = false

	if not pathing:
		return

	if move_to_unit != -1:
		var unit: Node2D = runner.unit_spawner.id_to_unit.get(move_to_unit, null)
		if unit:
			agent.target_position = unit.position
		else:
			move_to_unit = -1
			pathing = false
			return

	velocity = global_position.direction_to(agent.get_next_path_position()) * movement_speed
	animation.unit_direction = animation.vec_to_dir(velocity)
	var _hit := move_and_slide()

func cancel_move() -> void:
	pathing = false
	move_to_unit = -1

func _move_command_given(target: Vector2) -> void:
	agent.target_position = target
	move_to_unit = -1
	pathing = true

	var _ignore := runner.try_soft_interrupt()

func _move_to_unit(unit: Node2D) -> void:
	move_to_unit = runner.unit_spawner.unit_to_id[unit]
	pathing = true
	agent.target_position = unit.position

	var _ignore := runner.try_soft_interrupt()
