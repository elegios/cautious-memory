## Like [AbilitySeq], but transform a soft interrupt to a hard
## interrupt. This means that a player can interrupt the ability by
## giving a new command.
class_name Cancellable extends AbilitySeq

func interrupt(_kind: AInterruptKind) -> AInterruptResult:
	var c := current_child
	if c:
		return c.interrupt(AInterruptKind.Hard)
	return AInterruptResult.Interrupted
