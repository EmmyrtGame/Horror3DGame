class_name MainMenu
extends Control

const ESCENA_AJUSTES := preload("res://scenes/ui/ventana_ajustes.tscn")
const ESCENA_PARTIDAS := preload("res://scenes/ui/ventana_partidas.tscn")

@onready var btn_ajustes: Button = %ajustes_btn
@onready var btn_continuar: Button = %continuar_btn
@onready var btn_nueva_partida: Button = %nuevo_juego_btn
@onready var btn_cargar_partida: Button = %cargar_juego_btn

var ventana_ajustes: Window
var ventana_partidas: Window

func _ready() -> void:
	_update_continue_button()
	
	# Conectar señales del SaveManager para actualizar el botón continuar
	SaveManager.save_created.connect(_on_save_created)
	SaveManager.save_deleted.connect(_on_save_deleted)

func _update_continue_button() -> void:
	# Buscar la partida más reciente
	var latest_save_slot := _find_latest_save_slot()
	btn_continuar.disabled = latest_save_slot < 0

func _find_latest_save_slot() -> int:
	var all_saves := SaveManager.get_all_saves()
	var latest_slot := -1
	var latest_timestamp := 0
	
	for slot_id in all_saves.keys():
		var save_data: Dictionary = all_saves[slot_id]
		var timestamp: int = save_data.get("timestamp", 0)
		if timestamp > latest_timestamp:
			latest_timestamp = timestamp
			latest_slot = slot_id
	
	return latest_slot

func _on_continuar_btn_pressed() -> void:
	var latest_slot := _find_latest_save_slot()
	if latest_slot >= 0:
		_load_game(latest_slot)

func _on_nueva_partida_btn_pressed() -> void:
	_start_new_game()

func _on_cargar_partida_btn_pressed() -> void:
	if ventana_partidas == null:
		ventana_partidas = ESCENA_PARTIDAS.instantiate()
		add_child(ventana_partidas)
		ventana_partidas.game_load_requested.connect(_on_game_load_requested)
		ventana_partidas.new_game_requested.connect(_on_new_game_requested)
	
	ventana_partidas.call("open_modal")

func _on_ajustes_btn_pressed() -> void:
	if ventana_ajustes == null:
		ventana_ajustes = ESCENA_AJUSTES.instantiate()
		add_child(ventana_ajustes)
	ventana_ajustes.call("open_modal")

func _on_salir_btn_pressed() -> void:
	get_tree().quit()

func _on_game_load_requested(slot_id: int) -> void:
	_load_game(slot_id)

func _on_new_game_requested() -> void:
	_start_new_game()

func _load_game(slot_id: int) -> void:
	var save_data := SaveManager.load_game(slot_id)
	if save_data.size() > 0:
		_print_mensajes_testeo_cargar(save_data, slot_id)

func _start_new_game() -> void:
	var slot_id := SaveManager.create_new_game_save()
	if slot_id >= 0:
		_print_mensajes_testeo_nuevo_juego(slot_id)

func _on_save_created(_slot_id: int, _save_data: Dictionary) -> void:
	_update_continue_button()

func _on_save_deleted(_slot_id: int) -> void:
	_update_continue_button()


#-----------------------------------------------------------
# BOTONES DE TESTING - Remover en build final
@onready var btn_test_demos: Button = %test_demos_btn
@onready var btn_clear_saves: Button = %test_clear_btn
@onready var btn_print_saves: Button = %test_print_btn

# Funciones para testing - eliminar en build final
func _on_test_demos_btn_pressed() -> void:
	TestSaveManager.create_fresh_demos()

func _on_test_clear_btn_pressed() -> void:
	SaveManager.clear_all_saves()

func _on_test_print_btn_pressed() -> void:
	TestSaveManager.print_all_saves()

func _print_mensajes_testeo_cargar(save_data: Dictionary, slot_id: int) -> void:
	print("=== CARGANDO PARTIDA ===")
	print("Slot: ", slot_id)
	print("Level: ", save_data.get("level_name", "Unknown"))
	print("Playtime: ", save_data.get("playtime", "00:00:00"))
	print("Player Position: ", save_data.get("player_data", {}).get("position", Vector3.ZERO))
	print("Health: ", save_data.get("player_data", {}).get("health", 100))
	print("Inventory: ", save_data.get("player_data", {}).get("inventory", []))
	print("=====================")

func _print_mensajes_testeo_nuevo_juego(slot_id: int) -> void:
	print("=== NUEVA PARTIDA CREADA ===")
	print("Slot: ", slot_id)
	print("Iniciando en Hospital Entrance...")
	print("=============================")
	_load_game(slot_id)  # Cargar inmediatamente la nueva partida
#-----------------------------------------------------------
