class_name ATelegraph extends AbilityNode

@export var shape : Telegraph.Shape

@export var color : Color

## Where to position the telegraph. Center for circle. Optional,
## defaults to character position.
@export_custom(PROPERTY_HINT_EXPRESSION, "") var position: String
@onready var position_e: Expression = parse_expr(position) if position else null

## Radius of the telegraph. Only relevant if [code]shape[/code] is
## [code]Circle[/code].
@export_custom(PROPERTY_HINT_EXPRESSION, "") var radius: String
@onready var radius_e: Expression = parse_expr(radius) if radius else null

## Rotation of the telegraph, as a directional vector or an
## angle (radians). Optional, defaults to 0.0.
@export_custom(PROPERTY_HINT_EXPRESSION, "") var rotation: String
@onready var rotation_e: Expression = parse_expr(rotation) if rotation else null

func sync_gained() -> void:
	runner.telegraph.visible = true
	var _ignore := update_tele()

func sync_lost() -> void:
	runner.telegraph.visible = false

func pre_first_process() -> void:
	runner.telegraph.visible = true

func physics_process_ability(_delta: float) -> ARunResult:
	return update_tele()

func update_tele() -> ARunResult:
	var pres := run_expr(position, position_e) if position_e else ExprRes.new(runner.character.position)
	if pres.err == Err.ShouldBail or (pres.err == Err.MightBail and pres.value is not Vector2):
		sync_lost()
		return ARunResult.Error

	runner.telegraph.global_position = pres.value

	var rres := run_expr(rotation, rotation_e) if rotation_e else ExprRes.new(0.0)
	if rres.err == Err.ShouldBail or (rres.err == Err.MightBail and rres.value is not Vector2 and rres.value is not float):
		sync_lost()
		return ARunResult.Error

	if rres.value is Vector2:
		var v: Vector2 = rres.value
		runner.telegraph.rotation = v.angle()
	elif rres.value is float:
		runner.telegraph.rotation = rres.value

	if runner.telegraph.color != color:
		runner.telegraph.color = color
		runner.telegraph.queue_redraw()

	match shape:
		Telegraph.Shape.Circle:
			var res := run_expr(radius, radius_e) if radius_e else null
			if res.err == Err.ShouldBail or (res.err == Err.MightBail and res.value is not float):
				return ARunResult.Error

			if runner.telegraph.shape != shape:
				runner.telegraph.shape = shape
				runner.telegraph.queue_redraw()

			if runner.telegraph.radius != res.value:
				runner.telegraph.radius = res.value
				runner.telegraph.queue_redraw()

	return ARunResult.Wait

func interrupt(kind: AInterruptKind) -> AInterruptResult:
	var res := super(kind)
	if res == AInterruptResult.Interrupted:
		sync_lost()
	return res
