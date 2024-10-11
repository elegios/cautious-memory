@tool
class_name AnimationLayer extends Sprite2D

@export var layer : SpriteFrames:
	set(value):
		layer = value
		texture = layer.get_frame_texture(&"idle-se", 0)

func copy_frame(u: AnimatedUnit) -> void:
	if layer.has_animation(u.animation):
		texture = layer.get_frame_texture(u.animation, u.frame)
	else:
		texture = null
