extends Control

signal settings_changed(has_changes: bool)

# Referencias a sliders
@onready var music_slider: HSlider = %music_slider
@onready var sfx_slider: HSlider = %sfx_slider
@onready var master_slider: HSlider = %master_slider

# Índices de buses (se cachean en _ready)
var music_bus_idx: int = -1
var sfx_bus_idx: int = -1
var master_bus_idx: int = -1

# Valores aplicados (para restaurar si se cancela)
var applied_music_volume: float = 1.0
var applied_sfx_volume: float = 1.0
var applied_master_volume: float = 1.0

# Valores temporales (cambios en tiempo real)
var temp_music_volume: float = 1.0
var temp_sfx_volume: float = 1.0
var temp_master_volume: float = 1.0

func _ready() -> void:
	# Obtener índices de buses por nombre
	music_bus_idx = AudioServer.get_bus_index("Music")
	sfx_bus_idx = AudioServer.get_bus_index("SFX")
	master_bus_idx = AudioServer.get_bus_index("Master")
	
	# Cargar valores desde GameSettings (no desde AudioServer)
	_load_settings_from_config()
	
	music_slider.value_changed.connect(_on_music_volume_changed)
	sfx_slider.value_changed.connect(_on_sfx_volume_changed)
	master_slider.value_changed.connect(_on_master_volume_changed)

func _load_settings_from_config() -> void:
	# Cargar desde GameSettings, no desde AudioServer actual
	applied_music_volume = GameSettings.get_music_volume()
	applied_sfx_volume = GameSettings.get_sfx_volume()
	applied_master_volume = GameSettings.get_master_volume()

	# Inicializar valores temporales
	temp_music_volume = applied_music_volume
	temp_sfx_volume = applied_sfx_volume
	temp_master_volume = applied_master_volume

	# Actualizar sliders
	music_slider.value = applied_music_volume
	sfx_slider.value = applied_sfx_volume
	master_slider.value = applied_master_volume

	# Sin cambios al inicio
	_check_for_changes()

func _on_music_volume_changed(value: float) -> void:
	temp_music_volume = value
	if music_bus_idx >= 0:
		AudioServer.set_bus_volume_db(music_bus_idx, linear_to_db(value))
	_check_for_changes()

func _on_sfx_volume_changed(value: float) -> void:
	temp_sfx_volume = value
	if sfx_bus_idx >= 0:
		AudioServer.set_bus_volume_db(sfx_bus_idx, linear_to_db(value))
	_check_for_changes()

func _on_master_volume_changed(value: float) -> void:
	temp_master_volume = value
	if master_bus_idx >= 0:
		AudioServer.set_bus_volume_db(master_bus_idx, linear_to_db(value))
	_check_for_changes()

func _check_for_changes() -> void:
	# Comparar valores temporales con aplicados
	var has_changes = (
		not is_equal_approx(temp_music_volume, applied_music_volume) or
		not is_equal_approx(temp_sfx_volume, applied_sfx_volume) or
		not is_equal_approx(temp_master_volume, applied_master_volume)
	)
	emit_signal("settings_changed", has_changes)

func set_permanent_changes() -> void:
	# Guardar en ConfigFile, NO en ProjectSettings
	GameSettings.set_music_volume(temp_music_volume)
	GameSettings.set_sfx_volume(temp_sfx_volume)
	GameSettings.set_master_volume(temp_master_volume)
	GameSettings.save_settings()
	applied_music_volume = temp_music_volume
	applied_sfx_volume = temp_sfx_volume
	applied_master_volume = temp_master_volume
	emit_signal("settings_changed", false)
	emit_signal("settings_applied")

func restore_applied_volumes() -> void:
	# Restaurar valores en AudioServer
	if music_bus_idx >= 0:
		AudioServer.set_bus_volume_db(music_bus_idx, linear_to_db(applied_music_volume))
	if sfx_bus_idx >= 0:
		AudioServer.set_bus_volume_db(sfx_bus_idx, linear_to_db(applied_sfx_volume))
	if master_bus_idx >= 0:
		AudioServer.set_bus_volume_db(master_bus_idx, linear_to_db(applied_master_volume))

	# Restaurar valores en sliders
	music_slider.value = applied_music_volume  
	sfx_slider.value = applied_sfx_volume
	master_slider.value = applied_master_volume
	
	# Restaurar valores temporales
	temp_music_volume = applied_music_volume
	temp_sfx_volume = applied_sfx_volume
	temp_master_volume = applied_master_volume
	
	#sin cambios tras guardar
	emit_signal("settings_changed", false)
