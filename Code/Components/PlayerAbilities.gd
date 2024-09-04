class_name PlayerAbilities extends Node

signal move_cancelled

@export var runner : AbilityRunner

@export var abilities : Array[PlayerAbility]

## Try to run an ability, sending a soft interrupt to the currently
## running main ability, if one exists. Fails if:
## - Not called on the server
## - The main ability did not acknowledge the interrupt
func try_run_ability(id: int) -> bool:
	if not multiplayer or not multiplayer.is_server():
		return false

	var abi := abilities[id]

	if abi.is_main and not runner.try_soft_interrupt():
		return false

	var config := {
		&"path": abi.ability.resource_path,
		&"is_main": abi.is_main,
	}

	if abi.cancel_move:
		move_cancelled.emit()

	return runner.try_run_custom_ability(config)
