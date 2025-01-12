@icon("../Icons/Cancellable.svg")
## Like [AbilitySeq], but transform a soft interrupt to a hard
## interrupt. This means that a player can interrupt the ability by
## giving a new command.
class_name Cancellable extends AbilitySeq

func interrupt(_kind: AInterruptKind) -> AInterruptResult:
	var child := current_child
	if child:
		var res := child.interrupt(AInterruptKind.Hard)
		if res == AInterruptResult.Interrupted:
			child.deactivate()
			executing_idx = get_child_count()
		return res
	return AInterruptResult.Interrupted
