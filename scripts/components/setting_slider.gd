class_name SettingSlider
extends HSlider

signal setting_changed(value: float)

@export var category: String = ""
@export var setting_key: String = ""
@export var default_value: float = 1.0

var applied_value: float
var temp_value: float

func _ready() -> void:
	# Cargar si ya viene configurado desde el editor
	_load_setting()
	value_changed.connect(_on_value_changed)
	SettingsManager.settings_applied.connect(_on_settings_applied)

func bind(new_category: String, new_key: String, new_default: float = -1.0) -> void:
	# Permite re-vincular desde el panel y recargar desde SettingsManager
	category = new_category
	setting_key = new_key
	if new_default >= 0.0:
		default_value = new_default
	reload_from_settings()

func reload_from_settings() -> void:
	if category == "" or setting_key == "":
		return
	# Evitar emitir señales al setear value programáticamente
	set_block_signals(true)
	applied_value = SettingsManager.get_setting(category, setting_key, default_value)
	temp_value = applied_value
	value = applied_value
	set_block_signals(false)

func _load_setting() -> void:
	if category == "" or setting_key == "":
		return
	applied_value = SettingsManager.get_setting(category, setting_key, default_value)
	temp_value = applied_value
	value = applied_value

func _on_value_changed(new_value: float) -> void:
	temp_value = new_value
	SettingsManager.set_setting(category, setting_key, new_value)
	emit_signal("setting_changed", new_value)

func _on_settings_applied(applied_category: String) -> void:
	if applied_category == category:
		# Leer del manager para evitar desincronización
		applied_value = SettingsManager.get_setting(category, setting_key, default_value)

func restore_applied_value() -> void:
	set_block_signals(true)
	temp_value = applied_value
	value = applied_value
	set_block_signals(false)
	SettingsManager.set_setting(category, setting_key, applied_value)

func has_changes() -> bool:
	return not is_equal_approx(temp_value, applied_value)
