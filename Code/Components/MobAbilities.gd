class_name MobAbilities extends Node

@export var runner : AbilityRunner

@export var abilities : Array[MobAbility]

var abi_cd : Array[float]

func _ready() -> void:
	setup.call_deferred()

func setup() -> void:
	abi_cd = []
	for i in abilities.size():
		abilities = abilities.duplicate()
		abilities[i] = abilities[i].setup(runner)
		abi_cd.push_back(0.0)

func _physics_process(delta: float) -> void:
	if not multiplayer or not multiplayer.is_server():
		return

	for i in abi_cd.size():
		var abi := abilities[i]
		abi_cd[i] = maxf(abi_cd[i] - delta, 0.0)

		if abi_cd[i] <= 0:
			var condition_holds := true
			for c in abi.conditions:
				if not c.get_data(delta):
					condition_holds = false
					break
			if not condition_holds:
				continue
			var config := {
				&"path": abi.ability.resource_path,
				&"is_main": abi.is_main,
			}
			var success := runner.try_run_custom_ability(config, AbilityNode.AInterruptKind.Soft)
			if success:
				abi_cd[i] = abi.cooldown
