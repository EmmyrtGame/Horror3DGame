extends Node # AUTOLOAD | Settings Manager

signal setting_changed(category: String, key: String, value)
signal settings_applied(category: String)

var config := ConfigFile.new()
const SETTINGS_PATH := "user://settings.cfg"

var settings_cache := {}

func _ready() -> void:
	load_all_settings()
	_apply_all_settings_on_startup()

func load_all_settings() -> void:
	var err := config.load(SETTINGS_PATH)
	if err != OK:
		_create_default_config()
		save_all_settings()
	_cache_all_settings()

func _create_default_config() -> void:
	config.set_value("audio", "master_volume", 1.0)
	config.set_value("audio", "music_volume", 1.0)
	config.set_value("audio", "sfx_volume", 1.0)

func _cache_all_settings() -> void:
	settings_cache.clear()
	for section in config.get_sections():
		settings_cache[section] = {}
		for key in config.get_section_keys(section):
			settings_cache[section][key] = config.get_value(section, key)


func _apply_all_settings_on_startup() -> void:
	_apply_audio_settings()
	# Aquí se pueden agregar otras categorías
	# _apply_graphics_settings()
	# _apply_input_settings()

func _apply_audio_settings() -> void:
	var master_vol : float = get_setting("audio", "master_volume", 1.0)
	var music_vol : float = get_setting("audio", "music_volume", 1.0) 
	var sfx_vol : float= get_setting("audio", "sfx_volume", 1.0)
	
	var master_idx := AudioServer.get_bus_index("Master")
	var music_idx := AudioServer.get_bus_index("Music")
	var sfx_idx := AudioServer.get_bus_index("SFX")
	
	if master_idx >= 0:
		AudioServer.set_bus_volume_db(master_idx, linear_to_db(master_vol))
	
	if music_idx >= 0:
		AudioServer.set_bus_volume_db(music_idx, linear_to_db(music_vol))
	
	if sfx_idx >= 0:
		AudioServer.set_bus_volume_db(sfx_idx, linear_to_db(sfx_vol))

func get_setting(category: String, key: String, default_value = null):
	if settings_cache.has(category) and settings_cache[category].has(key):
		return settings_cache[category][key]
	return default_value

func set_setting(category: String, key: String, value) -> void:
	if not settings_cache.has(category):
		settings_cache[category] = {}
	settings_cache[category][key] = value
	config.set_value(category, key, value)
	emit_signal("setting_changed", category, key, value)

func save_all_settings() -> void:
	var err := config.save(SETTINGS_PATH)

func apply_category(category: String) -> void:
	if category == "audio":
		_apply_audio_settings()
	emit_signal("settings_applied", category)
