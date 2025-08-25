class_name SettingsWindow
extends Window

signal settings_applied

@onready var first_focus: Control = %first_focus
@onready var btn_aplicar: Button = %aplicar_btn
@onready var audio_settings: Control = %Audio

func _ready() -> void:
	audio_settings.connect("settings_changed", _on_settings_changed)

func open_modal(min_size: Vector2i = Vector2i(900, 650), max_ratio: float = 0.85) -> void:
	btn_aplicar.disabled = true
	# Abre centrada y limitada al tamaño de la ventana padre
	popup_centered_clamped(min_size, max_ratio)
	# Dar tiempo a que aparezca y enfocar el primer control
	await get_tree().process_frame
	if is_instance_valid(first_focus):
		first_focus.grab_focus()

func _on_settings_changed(has_changes: bool) -> void:
	# Activar/desactivar botón aplicar según cambios
	btn_aplicar.disabled = not has_changes

func _on_salir_btn_pressed() -> void:
	audio_settings.call("restore_applied_volumes")
	hide()

func _on_aplicar_btn_pressed() -> void:
	audio_settings.call("set_permanent_changes")
	btn_aplicar.disabled = true

func _on_close_requested() -> void:
	audio_settings.call("restore_applied_volumes")
	hide()
