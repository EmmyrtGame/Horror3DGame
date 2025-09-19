class_name SaveGamePanel
extends Control

signal save_slot_selected(slot_id: int)
signal save_slot_deleted(slot_id: int)

@onready var slots_container: VBoxContainer = %slots_container
@onready var confirm_delete_dialog: ConfirmationDialog = %confirm_delete_dialog

const SAVE_SLOT_SCENE := preload("res://scenes/ui/save_slot.tscn")

var save_slots: Array[SaveSlot] = []
var pending_delete_slot_id: int = -1

func _ready() -> void:
	_create_save_slots()
	confirm_delete_dialog.confirmed.connect(_on_delete_confirmed)

func _create_save_slots() -> void:
	# Limpiar slots existentes
	for slot in save_slots:
		slot.queue_free()
	save_slots.clear()
	
	# Crear nuevos slots
	for i in range(SaveManager.MAX_SAVE_SLOTS):
		var slot_scene := SAVE_SLOT_SCENE.instantiate()
		var slot := slot_scene as SaveSlot
		
		slots_container.add_child(slot)
		slot.setup_slot(i)
		slot.slot_selected.connect(_on_slot_selected)
		slot.slot_deleted.connect(_on_slot_delete_requested)
		
		save_slots.append(slot)

func refresh_all_slots() -> void:
	for slot in save_slots:
		slot.refresh_display()

func _on_slot_selected(slot_id: int) -> void:
	emit_signal("save_slot_selected", slot_id)

func _on_slot_delete_requested(slot_id: int) -> void:
	pending_delete_slot_id = slot_id
	confirm_delete_dialog.dialog_text = "¿Estás seguro de que quieres eliminar la partida del Slot %d?" % (slot_id + 1)
	confirm_delete_dialog.popup_centered()

func _on_delete_confirmed() -> void:
	if pending_delete_slot_id >= 0:
		SaveManager.delete_save(pending_delete_slot_id)
		emit_signal("save_slot_deleted", pending_delete_slot_id)
		pending_delete_slot_id = -1
