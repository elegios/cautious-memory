extends Node

## The animation to play on death.
@export var death_animation : AnimatedUnit.A

## The duration of the animation. Optional, a negative number will
## preserve the original duration.
@export var death_animation_duration := -1.0

## The component with which to play the animation.
@export var animation : AnimatedUnit

## The ability runner to hard interrupt
@export var runner : AbilityRunner

@export var to_disable : Array[Node]
@export var to_hide : Array[CanvasItem]

func _on_death() -> void:
	_do_death.rpc()

@rpc("authority", "call_local", "reliable")
func _do_death() -> void:
	for n in to_disable:
		n.process_mode = Node.PROCESS_MODE_DISABLED
	for n in to_hide:
		n.visible = false
	if runner:
		runner.hard_interrupt()

	animation.process_mode = Node.PROCESS_MODE_PAUSABLE
	animation.set_overlay(death_animation, AnimatedUnit.Dir.None, death_animation_duration)
	var _ignore := animation.animation_finished.connect(_on_death_finished, ConnectFlags.CONNECT_ONE_SHOT)

func _on_death_finished() -> void:
	if multiplayer.is_server():
		get_parent().queue_free()
