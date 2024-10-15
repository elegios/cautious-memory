@tool
extends EditorImportPlugin

var editor: EditorInterface

func _init(e: EditorInterface) -> void:
	editor = e

func _get_importer_name() -> String:
	return "2d-pixel-skins-animation-importer"

func _get_visible_name() -> String:
	return "2D Pixel Skin Animation"

func _get_recognized_extensions() -> PackedStringArray:
	return ["png"]

func _get_priority() -> float:
	return 1.0

# NOTE(vipa, 2024-10-14): Not sure about this one
func _get_save_extension() -> String:
	return "res"

# NOTE(vipa, 2024-10-14): Not sure about this one
func _get_resource_type() -> String:
	return "AtlasTexture"

func _get_import_order() -> int:
	# NOTE(vipa, 2024-10-15): After the skin map importer
	return 1

enum Preset { Default, CustomMap }

func _get_preset_count() -> int:
	return Preset.size()

func _get_preset_name(preset_index: int) -> String:
	match preset_index:
		Preset.Default:
			return "Default"
		Preset.CustomMap:
			return "Custom map"
		_:
			return "Unknown"


# NOTE(vipa, 2024-10-14): This should almost certainly be changed
func _get_import_options(path: String, preset_index: int) -> Array[Dictionary]:
	var SKIN_MAP = {
		"name": "skin_map",
		"default_value": SkinMapData.new(),
		"description": "The skin map to use to convert an animation to proper uv coordinates.",
		"property_hint": PROPERTY_HINT_RESOURCE_TYPE,
		"hint_string": "SkinMapData",
	}
	match preset_index:
		Preset.Default:
			return [SKIN_MAP]
		Preset.CustomMap:
			return [SKIN_MAP]
		_:
			return [SKIN_MAP]

func _get_option_visibility(_path: String, _option_name: StringName, _options: Dictionary) -> bool:
	return true

func _import(source_file: String, save_path: String, options: Dictionary, platform_variants: Array[String], gen_files: Array[String]) -> Error:
	var original := Image.load_from_file(ProjectSettings.globalize_path(source_file))

	var map : SkinMapData = options.skin_map

	for x in original.get_width():
		for y in original.get_height():
			var c := original.get_pixel(x, y)
			if c.a8 > 0:
				original.set_pixel(x, y, map.color_locations[c])

	var source_folder := source_file.rsplit("/", true, 1)[0]
	var source_basename := source_file.rsplit("/", true, 1)[1].trim_suffix(".png").trim_suffix(".anim")

	var converted_dir := "%s/converted" % source_folder
	var converted_path := "%s/%s.conv.png" % [converted_dir, source_basename]

	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(converted_dir))
	var res := original.save_png(converted_path)
	if res != OK:
		return res

	editor.get_resource_filesystem().update_file(converted_dir)
	editor.get_resource_filesystem().update_file(converted_path)
	append_import_external_resource(converted_path)

	var ctexture : CompressedTexture2D = ResourceLoader.load(converted_path, "CompressedTexture2D", ResourceLoader.CACHE_MODE_REPLACE)

	var texture := AtlasTexture.new()
	texture.atlas = ctexture

	res = ResourceSaver.save(texture, "%s.%s" % [save_path, _get_save_extension()])

	return res
