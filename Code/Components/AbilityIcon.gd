class_name AbilityIcon extends Control

var cd_max : float:
	set(value):
		cd_max = value
		_update_visualization()
var cd_remaining : float:
	set(value):
		cd_remaining = value
		_update_visualization()
var charges := 1

@onready var progress : TextureProgressBar = %Progress
@onready var progress_label : Label = %ProgressLabel

func _update_visualization() -> void:
	if cd_remaining > 0:
		if cd_remaining > 10:
			progress_label.text = str(int(cd_remaining))
		else:
			progress_label.text = "%.1f" % cd_remaining
		progress.value = cd_remaining / cd_max * progress.max_value
	else:
		progress_label.text = ""
		progress.value = 0
