class_name SaveGameWindow
extends Window

signal game_load_requested(slot_id: int)
signal new_game_requested()

@onready var save_panel: SaveGamePanel = %save_panel
@onready var load_button: Button = %cargar_btn
@onready var new_game_button: Button = %nuevo_juego_btn
@onready var close_button: Button = %cerrar_btn

var selected_slot_id: int = -1

func _ready() -> void:
	save_panel.save_slot_selected.connect(_on_slot_selected)
	save_panel.save_slot_deleted.connect(_on_slot_deleted)
	
	load_button.pressed.connect(_on_load_button_pressed)
	new_game_button.pressed.connect(_on_new_game_button_pressed)
	close_button.pressed.connect(_on_close_button_pressed)
	
	close_requested.connect(_on_close_requested)
	
	_update_buttons_state()

func _on_slot_selected(slot_id: int) -> void:
	selected_slot_id = slot_id
	_update_buttons_state()

func _on_slot_deleted(slot_id: int) -> void:
	if selected_slot_id == slot_id:
		selected_slot_id = -1
	_update_buttons_state()

func _update_buttons_state() -> void:
	var has_valid_save := selected_slot_id >= 0 and SaveManager.has_save(selected_slot_id)
	load_button.disabled = not has_valid_save

func _on_load_button_pressed() -> void:
	if selected_slot_id >= 0 and SaveManager.has_save(selected_slot_id):
		emit_signal("game_load_requested", selected_slot_id)
		hide()

func _on_new_game_button_pressed() -> void:
	emit_signal("new_game_requested")
	hide()

func _on_close_button_pressed() -> void:
	hide()

func _on_close_requested() -> void:
	hide()

func open_modal() -> void:
	popup_centered_clamped()
	save_panel.refresh_all_slots()
	selected_slot_id = -1
	_update_buttons_state()
