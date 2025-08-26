class_name SettingsWindow
extends Window

@onready var btn_aplicar: Button = %aplicar_btn
@onready var audio_settings: Control = %Audio
@onready var unsaved_dialog: ConfirmationDialog = $ConfirmacionDeCambios

var has_unsaved_changes: bool = false

func _ready() -> void:
	audio_settings.connect("settings_changed", _on_settings_changed)

func open_modal() -> void:
	btn_aplicar.disabled = true
	has_unsaved_changes = false
	# Abre centrada y limitada al tamaño de la ventana padre
	popup_centered_clamped()
	# Dar tiempo a que aparezca y enfocar el primer control
	await get_tree().process_frame

func _on_settings_changed(has_changes: bool) -> void:
	# Activar/desactivar botón aplicar según cambios
	btn_aplicar.disabled = not has_changes
	has_unsaved_changes = has_changes

func _on_aplicar_btn_pressed() -> void:
	audio_settings.call("set_permanent_changes")
	btn_aplicar.disabled = true
	has_unsaved_changes = false

func _on_salir_btn_pressed() -> void:
	_attempt_to_close()

func _on_close_requested() -> void:
	_attempt_to_close()

func _attempt_to_close() -> void:
	if has_unsaved_changes:
		# Mostrar diálogo de confirmación
		unsaved_dialog.popup_centered()
	else:
		# Cerrar directamente si no hay cambios
		_close_window()

func _on_confirmacion_de_cambios_confirmed() -> void:
	_close_window()

func _on_confirmacion_de_cambios_canceled() -> void:
	pass # Cancelamos el proceso

func _close_window() -> void:
	# Restaurar valores solo si hay cambios no guardados
	if has_unsaved_changes:
		audio_settings.call("restore_applied_volumes")
	has_unsaved_changes = false
	hide()
