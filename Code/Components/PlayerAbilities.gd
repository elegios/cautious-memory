class_name PlayerAbilities extends Node

signal move_cancelled

@export var runner : AbilityRunner

## The abilities directly usable by this player character. Index 0 is
## the auto-attack.
@export var abilities : Array[PlayerAbility]

## Try to run an ability, sending a soft interrupt to the currently
## running main ability, if one exists. Fails if:
## - Not called on the server
## - The main ability did not acknowledge the interrupt
func try_run_ability(id: int) -> bool:
	if not multiplayer or not multiplayer.is_server():
		return false

	var abi := abilities[id]

	var config := {
		&"path": abi.ability.resource_path,
		&"is_main": abi.is_main,
	}

	var success := runner.try_run_custom_ability(config, AbilityNode.AInterruptKind.Soft)

	if success and abi.cancel_move:
		move_cancelled.emit()

	return success
