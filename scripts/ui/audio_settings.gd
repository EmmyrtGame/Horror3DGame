class_name AudioSettingsPanel
extends Control

signal has_changes_updated(has_changes: bool)

@onready var master_slider: SettingSlider = %master_slider
@onready var music_slider: SettingSlider = %music_slider
@onready var sfx_slider: SettingSlider = %sfx_slider

var sliders: Array[SettingSlider] = []
var bus_indices := {}

func _ready() -> void:
	_setup_sliders()
	_cache_bus_indices()
	_connect_signals()
	await get_tree().process_frame
	_check_for_changes()

func _setup_sliders() -> void:
	sliders = [master_slider, music_slider, sfx_slider]
	# Vincula claves y recarga desde SettingsManager
	master_slider.bind("audio", "master_volume")
	music_slider.bind("audio", "music_volume")
	sfx_slider.bind("audio", "sfx_volume")

func _cache_bus_indices() -> void:
	bus_indices["Master"] = AudioServer.get_bus_index("Master")
	bus_indices["Music"] = AudioServer.get_bus_index("Music")
	bus_indices["SFX"] = AudioServer.get_bus_index("SFX")

func _connect_signals() -> void:
	for slider in sliders:
		slider.setting_changed.connect(_on_slider_changed)
	SettingsManager.setting_changed.connect(_on_setting_changed)

func _on_slider_changed(_value: float) -> void:
	_check_for_changes()

func _on_setting_changed(category: String, key: String, value) -> void:
	if category != "audio":
		return
	var bus_name := _get_bus_name_for_key(key)
	if bus_name != "" and bus_indices.has(bus_name):
		var bus_idx: int = bus_indices[bus_name]
		if bus_idx >= 0:
			AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))

func _get_bus_name_for_key(key: String) -> String:
	match key:
		"master_volume": return "Master"
		"music_volume": return "Music"
		"sfx_volume": return "SFX"
		_: return ""

func _check_for_changes() -> void:
	var changes := has_changes()
	emit_signal("has_changes_updated", changes)

func has_changes() -> bool:
	for slider in sliders:
		if slider.has_changes():
			return true
	return false

func apply_changes() -> void:
	SettingsManager.save_all_settings()
	SettingsManager.apply_category("audio")

func discard_changes() -> void:
	for slider in sliders:
		slider.restore_applied_value()
	_check_for_changes()
