class_name Telegraph extends Node2D

enum Shape { Circle }

@export var shape : Shape

## Only relevant if [code]shape[/code] is [code]Circle[/code]. The
## radius of the telegraph.
@export var radius : float

## The color of the telegraph. The alpha value is irrelevant and will
## instead be taken from [code]border_alpha[/code] and
## [code]fill_alpha[/code].
@export var color : Color

## Alpha of the inside of the telegraph, 0.0 (invisible) to 1.0 (fully
## visible).
@export var fill_alpha : float = 0.3

## Alpha of the telegraph border, 0.0 (invisible) to 1.0 (fully
## visible).
@export var border_alpha : float = 0.7

## Thickness of the border.
@export var border_thickness : float = 2

func _draw() -> void:
	match shape:
		Shape.Circle:
			draw_circle(Vector2.ZERO, radius, Color(color.r, color.g, color.b, fill_alpha), true)
			draw_circle(Vector2.ZERO, radius, Color(color.r, color.g, color.b, border_alpha), false, border_thickness)
		_:
			pass
