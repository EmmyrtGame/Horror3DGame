class_name SettingsWindow
extends Window

@onready var apply_btn: Button = %aplicar_btn
@onready var cancel_btn: Button = %salir_btn
@onready var tab_container: TabContainer = %TabContainer
@onready var unsaved_dialog: ConfirmationDialog = %ConfirmacionDeCambios

var settings_panels: Array[Control] = []
var has_unsaved_changes := false

func _ready() -> void:
	_collect_settings_panels()
	_connect_panel_signals()
	
	apply_btn.pressed.connect(_on_apply_pressed)
	cancel_btn.pressed.connect(_on_cancel_pressed)

func _collect_settings_panels() -> void:
	for child in tab_container.get_children():
		if child.has_signal("has_changes_updated"):
			settings_panels.append(child)

func _connect_panel_signals() -> void:
	for panel in settings_panels:
		panel.has_changes_updated.connect(_on_panel_changes_updated)

func _on_panel_changes_updated(_has_changes: bool) -> void:
	_update_buttons_state()

func _update_buttons_state() -> void:
	has_unsaved_changes = false
	for panel in settings_panels:
		if panel.has_method("has_changes") and panel.has_changes():
			has_unsaved_changes = true
			break
	
	apply_btn.disabled = not has_unsaved_changes

func _on_apply_pressed() -> void:
	for panel in settings_panels:
		if panel.has_method("apply_changes"):
			panel.apply_changes()
	
	has_unsaved_changes = false
	_update_buttons_state()

func _on_cancel_pressed() -> void:
	_attempt_close()

func _on_close_requested() -> void:
	_attempt_close()

func _attempt_close() -> void:
	if has_unsaved_changes:
		unsaved_dialog.popup_centered()
	else:
		hide()

func open_modal() -> void:
	popup_centered_clamped()
	_update_buttons_state()


func _on_confirmacion_de_cambios_confirmed() -> void:
	for panel in settings_panels:
		if panel.has_method("discard_changes"):
			panel.discard_changes()
	hide()
