class_name PlayerAbility extends Resource

## Whether the ability should be a main ability. If true, requires the
## current main ability (if any) to acknowledge a soft
## interrupt. Always succeeds if false.
@export var is_main : bool = true

## Whether movement should be cancelled when the ability is
## activated. If [code]cancel_move[/code] is false and
## [code]is_main[/code] is true, then movement is merely paused while
## the ability runs.
@export var cancel_move : bool = true

## The ability to run.
@export var ability : PackedScene

## The description to be shown when hovering over the ability icon
@export_multiline var description : String

@export_group("Cooldown")

## Cooldown to apply to this ability when used. Applied after a charge
## is used and at least one still remains. Useful for preventing spam
## and/or accidental double activations.
@export var cooldown : float

## Maximum number of charges.
@export var max_charges := 1

## Amount of time required to regain a charge. Typically higher than
## [property PlayerAbility.cooldown]. Ticks in the foreground if no
## charges remain, otherwise in the background.
@export var charge_cooldown : float
