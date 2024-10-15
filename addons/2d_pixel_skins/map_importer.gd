@tool
extends EditorImportPlugin

func _get_importer_name() -> String:
	return "2d-pixel-skins-map-importer"

func _get_visible_name() -> String:
	return "2D Pixel Skin Map"

func _get_recognized_extensions() -> PackedStringArray:
	return ["png"]

func _get_import_order() -> int:
	return 0

func _get_priority() -> float:
	return 1.0

# NOTE(vipa, 2024-10-14): Not sure about this one
func _get_save_extension() -> String:
	return "res"

# NOTE(vipa, 2024-10-14): Not sure about this one
func _get_resource_type() -> String:
	return "Resource"

enum Preset { Default }

func _get_preset_count() -> int:
	return Preset.size()

func _get_preset_name(preset_index: int) -> String:
	match preset_index:
		Preset.Default:
			return "Default"
		_:
			return "Unknown"

# NOTE(vipa, 2024-10-14): This should almost certainly be changed
func _get_import_options(path: String, preset_index: int) -> Array[Dictionary]:
	match preset_index:
		Preset.Default:
			return []
		_:
			return []

func _get_option_visibility(_path: String, _option_name: StringName, _options: Dictionary) -> bool:
	return true

func _import(source_file: String, save_path: String, options: Dictionary, platform_variants: Array[String], gen_files: Array[String]) -> Error:
	var original := Image.load_from_file(ProjectSettings.globalize_path(source_file))

	var data := SkinMapData.new()

	for x in original.get_width():
		for y in original.get_height():
			var c := original.get_pixel(x, y)
			if c.a8 > 0:
				data.color_locations[c] = Color8(x, y, 0)

	return ResourceSaver.save(data, "%s.%s" % [save_path, _get_save_extension()])
