class_name TestComponent extends AbilityNode

func physics_process_ability(_delta: float, _first: bool) -> ARunResult:
	runner.character.collision_mask &= ~1
	runner.character.collision_layer &= ~1
	var coll := runner.character.get_last_slide_collision()
	if coll:
		print(coll.get_collider())
	else:
		print("no collision")
	return ARunResult.Wait

func interrupt(kind: AInterruptKind) -> AInterruptResult:
	match kind:
		AInterruptKind.Hard, AInterruptKind.Counter:
			runner.character.collision_mask |= 1
			runner.character.collision_layer |= 1
			return AInterruptResult.Interrupted
		AInterruptKind.Soft:
			return AInterruptResult.Uninterrupted
		_:
			assert(false, "Impossible")
			return AInterruptResult.Interrupted
