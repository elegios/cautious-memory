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

@export_group("Targeting")

## This ability can target a point. Sets the [code]target_point[/code]
## property in the executed ability.
@export var can_target_point := true

## If this ability can target a unit, it must be on at least one of
## these layers. Sets the [code]target_unit[/code] blackboard property
## in the executed ability. Disable all layers to disable unit
## targeting.
@export_flags_2d_physics var unit_filter := 0

## When looking for a unit to target, do it with a shapecast circle
## with this radius.
@export var unit_target_radius := 40.0

## Max cast-range of ability. Used both for mechanics and
## visualization. A non-positive number means infinite/irrelevant.
@export var max_range : float

## If the ability is used outside of range, walk towards the target
## until in range before casting. If false, set the target to the
## closest point within range (if the ability can target a point) or
## fail (if it cannot target a point).
@export var walk_in_range := true

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
