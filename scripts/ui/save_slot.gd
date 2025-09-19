class_name SaveSlot
extends Control

signal slot_selected(slot_id: int)
signal slot_deleted(slot_id: int)

@onready var slot_button: Button = %slot_button
@onready var delete_button: Button = %delete_button
@onready var level_label: Label = %level_label
@onready var playtime_label: Label = %playtime_label
@onready var timestamp_label: Label = %timestamp_label
@onready var screenshot_rect: TextureRect = %screenshot_rect

var slot_id: int = -1
var save_data: Dictionary = {}
var is_empty: bool = true

func _ready() -> void:
	slot_button.pressed.connect(_on_slot_button_pressed)
	delete_button.pressed.connect(_on_delete_button_pressed)
	
	# Conectar a señales del SaveManager
	SaveManager.save_created.connect(_on_save_created)
	SaveManager.save_deleted.connect(_on_save_deleted)

func setup_slot(new_slot_id: int) -> void:
	slot_id = new_slot_id
	refresh_display()

func refresh_display() -> void:
	if SaveManager.has_save(slot_id):
		save_data = SaveManager.get_save_info(slot_id)
		_display_save_data()
		is_empty = false
	else:
		_display_empty_slot()
		is_empty = true
	
	delete_button.visible = not is_empty

func _display_save_data() -> void:
	var level_name: String = save_data.get("level_name", "Unknown Level")
	var playtime: String = save_data.get("playtime", "00:00:00")
	var timestamp: int = save_data.get("timestamp", 0)
	
	slot_button.text = "Slot %d" % (slot_id + 1)
	level_label.text = level_name
	playtime_label.text = "Playtime: " + playtime
	timestamp_label.text = _format_timestamp(timestamp)
	
	# Cargar screenshot si existe
	var screenshot_path: String = save_data.get("screenshot_path", "")
	if screenshot_path != "" and FileAccess.file_exists(screenshot_path):
		var texture := load(screenshot_path)
		if texture != null:
			screenshot_rect.texture = texture

func _display_empty_slot() -> void:
	slot_button.text = "Espacio vacio %d" % (slot_id + 1)
	level_label.text = "No hay datos guardados"
	playtime_label.text = ""
	timestamp_label.text = ""
	screenshot_rect.texture = null

func _format_timestamp(timestamp: int) -> String:
	var datetime := Time.get_datetime_dict_from_unix_time(timestamp)
	return "%04d/%02d/%02d %02d:%02d" % [
		datetime.year, datetime.month, datetime.day,
		datetime.hour, datetime.minute
	]

func _on_slot_button_pressed() -> void:
	emit_signal("slot_selected", slot_id)

func _on_delete_button_pressed() -> void:
	emit_signal("slot_deleted", slot_id)

func _on_save_created(created_slot_id: int, _data: Dictionary) -> void:
	if created_slot_id == slot_id:
		refresh_display()

func _on_save_deleted(deleted_slot_id: int) -> void:
	if deleted_slot_id == slot_id:
		refresh_display()
