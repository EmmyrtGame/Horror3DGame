## autoload/game_settings.gd (mejor práctica)
extends Node

var config := ConfigFile.new()
const SETTINGS_PATH := "user://settings.cfg"

# Valores por defecto
var default_music_volume := 1.0
var default_sfx_volume := 1.0
var default_master_volume := 1.0

func _ready() -> void:
	load_settings()

func load_settings() -> void:
	var err := config.load(SETTINGS_PATH)
	if err != OK:
		# Primera vez: crear archivo con valores por defecto
		create_default_settings()
		save_settings()
	# Aplicar valores cargados a AudioServer
	apply_audio_settings()

func create_default_settings() -> void:
	config.set_value("audio", "music_volume", default_music_volume)
	config.set_value("audio", "sfx_volume", default_sfx_volume)
	config.set_value("audio", "master_volume", default_master_volume)

func get_music_volume() -> float:
	return config.get_value("audio", "music_volume", default_music_volume)

func get_sfx_volume() -> float:
	return config.get_value("audio", "sfx_volume", default_sfx_volume)

func get_master_volume() -> float:
	return config.get_value("audio", "master_volume", default_master_volume)

func set_music_volume(volume: float) -> void:
	config.set_value("audio", "music_volume", volume)

func set_sfx_volume(volume: float) -> void:
	config.set_value("audio", "sfx_volume", volume)

func set_master_volume(volume: float) -> void:
	config.set_value("audio", "master_volume", volume)

func save_settings() -> void:
	config.save(SETTINGS_PATH)

func apply_audio_settings() -> void:
	var music_idx := AudioServer.get_bus_index("Music")
	var sfx_idx := AudioServer.get_bus_index("SFX")
	var master_idx := AudioServer.get_bus_index("Master")
	if music_idx >= 0:
		AudioServer.set_bus_volume_db(music_idx, linear_to_db(get_music_volume()))
	if sfx_idx >= 0:
		AudioServer.set_bus_volume_db(sfx_idx, linear_to_db(get_sfx_volume()))
	if master_idx >= 0:
		AudioServer.set_bus_volume_db(master_idx, linear_to_db(get_master_volume()))
