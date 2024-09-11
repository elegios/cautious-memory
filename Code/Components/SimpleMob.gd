extends CharacterBody2D

## The movement speed of this enemy, in pixels per second.
@export var movement_speed: float = 96

@onready var movement: MobMovement = %Movement

func _physics_process(_delta: float) -> void:
	var dir := movement.get_movement_direction()

	if dir.is_zero_approx():
		return

	velocity = dir.normalized() * movement_speed
	var _collided := move_and_slide()
