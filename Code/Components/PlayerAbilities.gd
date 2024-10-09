class_name PlayerAbilities extends Node

signal move_cancelled

var controller: int:
	set(value):
		controller = value
		var abi_cont := %"AbilityContainer" as Control
		if abi_cont:
			abi_cont.visible = value == multiplayer.get_unique_id()

@export var runner : AbilityRunner

@export var ability_icon : PackedScene

## The abilities directly usable by this player character. Index 0 is
## the auto-attack.
@export var abilities : Array[PlayerAbility]

# NOTE(vipa, 2024-10-07): cd remaining in seconds
var cooldowns : Array[float]
var charge_cooldowns : Array[float]
var charges : Array[int]
var ability_icons : Array[AbilityIcon]

func _ready() -> void:
	cooldowns = []
	charge_cooldowns = []
	charges = []
	for i in abilities.size():
		cooldowns.push_back(0)
		charge_cooldowns.push_back(0)
		charges.push_back(abilities[i].max_charges)

		var abi_i: AbilityIcon = ability_icon.instantiate()
		abi_i.tooltip_text = abilities[i].description
		%"AbilityContainer".add_child(abi_i)
		ability_icons.push_back(abi_i)

## Try to run an ability, sending a soft interrupt to the currently
## running main ability, if one exists. Fails if:
## - Not called on the server
## - No charge is available/the ability is on cooldown
## - The main ability did not acknowledge the interrupt
func try_run_ability(id: int) -> bool:
	if not multiplayer or not multiplayer.is_server():
		return false

	if charges[id] == 0 or cooldowns[id] > 0:
		return false

	var abi := abilities[id]

	var config := {
		&"path": abi.ability.resource_path,
		&"is_main": abi.is_main,
	}

	var success := runner.try_run_custom_ability(config, AbilityNode.AInterruptKind.Soft)

	if success:
		cooldowns[id] = abi.cooldown
		if abi.charge_cooldown > 0:
			charges[id] -= 1
			if charge_cooldowns[id] <= 0:
				charge_cooldowns[id] = abi.charge_cooldown

		if abi.cancel_move:
			move_cancelled.emit()

	return success

func _physics_process(delta: float) -> void:
	for i in cooldowns.size():
		cooldowns[i] = maxf(0.0, cooldowns[i] - delta)

	for i in charge_cooldowns.size():
		if charge_cooldowns[i] <= 0:
			continue
		charge_cooldowns[i] -= delta
		if charge_cooldowns[i] <= 0:
			charges[i] += 1
			if charges[i] < abilities[i].max_charges:
				charge_cooldowns[i] = abilities[i].charge_cooldown

	for i in ability_icons.size():
		var abi_i := ability_icons[i]
		abi_i.charges = charges[i]
		var cd_remaining := cooldowns[i]
		var cd_max := abilities[i].cooldown
		if charges[i] == 0 and charge_cooldowns[i] > cd_remaining:
			cd_remaining = charge_cooldowns[i]
			cd_max = abilities[i].charge_cooldown
		abi_i.cd_remaining = cd_remaining
		abi_i.cd_max = cd_max
