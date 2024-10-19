class_name PlayerAbilityScript extends AbilityScript

## Whether the ability should be a main ability. If true, requires the
## current main ability (if any) to acknowledge a soft
## interrupt. Always succeeds if false.
func _is_main() -> bool:
	return true

## Whether movement should be cancelled when the ability is
## activated. If [code]cancel_move[/code] is false and
## [code]is_main[/code] is true, then movement is merely paused while
## the ability runs.
func _cancel_move() -> bool:
	return true

## The description to be shown when hovering over the ability icon
func _description() -> String:
	return ""


# === Targeting ===

## This ability can target a point. Sets the [code]target_point[/code]
## property in the executed ability.
func _can_target_point() -> bool:
	return true

## If this ability can target a unit, it must be on at least one of
## these layers. Sets the [code]target_unit[/code] blackboard property
## in the executed ability. Disable all layers to disable unit
## targeting.
func _unit_filter() -> int:
	return 0

## When looking for a unit to target, do it with a shapecast circle
## with this radius.
func _unit_target_radius() -> float:
	return 40.0

## Max cast-range of ability. Used both for mechanics and
## visualization. A non-positive number means infinite/irrelevant.
func _max_range() -> float:
	return 0.0

## If the ability is used outside of range, walk towards the target
## until in range before casting. If false, set the target to the
## closest point within range (if the ability can target a point) or
## fail (if it cannot target a point).
func _walk_in_range() -> bool:
	return true


# === Cooldown ===

## Cooldown to apply to this ability when used. Applied after a charge
## is used and at least one still remains. Useful for preventing spam
## and/or accidental double activations.
@export var cooldown : float

## Cooldown to apply to this ability when used. Applied after a charge
## is used and at least one still remains. Useful for preventing spam
## and/or accidental double activations.
func _cooldown() -> float:
	return cooldown

## Maximum number of charges.
@export var max_charges := 1

## Maximum number of charges.
func _max_charges() -> int:
	return max_charges

## Amount of time required to regain a charge. Typically higher than
## [property PlayerAbilityScript.cooldown]. Ticks in the foreground if
## no charges remain, otherwise in the background.
@export var charge_cooldown : float

## Amount of time required to regain a charge. Typically higher than
## [property PlayerAbilityScript.cooldown]. Ticks in the foreground if
## no charges remain, otherwise in the background.
func _charge_cooldown() -> float:
	return charge_cooldown
