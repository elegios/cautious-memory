@icon("../Icons/Character.svg")
## Destroy the Character attached to the AbilityRunner. Should be the
## last action to run; it will only complete on the server.
class_name DestroySelf extends AbilityNode

func physics_process_ability(_delta: float) -> ARunResult:
	if multiplayer.is_server():
		runner.character.queue_free()
		return ARunResult.Done
	return ARunResult.Wait
