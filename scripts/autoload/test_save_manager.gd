extends Node # AUTOLOAD | Test Save Manager

func _ready() -> void:
	# Auto-crear partidas demo en la primera ejecución
	if _should_create_demo_saves():
		call_deferred("_setup_demo_environment")

func _should_create_demo_saves() -> bool:
	# Crear demos si no hay partidas guardadas
	return SaveManager.get_all_saves().size() == 0

func _setup_demo_environment() -> void:
	print("=== CONFIGURANDO ENTORNO DE TESTING ===")
	SaveManager.create_demo_saves()
	print("=== PARTIDAS DEMO CREADAS ===")

# Métodos para testing manual desde consola o botones
func create_fresh_demos() -> void:
	SaveManager.clear_all_saves()
	SaveManager.create_demo_saves()
	print("Demos recreados")

func create_test_new_game() -> void:
	var slot_id := SaveManager.create_new_game_save()
	if slot_id >= 0:
		print("Nueva partida de prueba creada en slot ", slot_id)

func print_all_saves() -> void:
	print("=== TODAS LAS PARTIDAS ===")
	var all_saves := SaveManager.get_all_saves()
	for slot_id in all_saves.keys():
		var save_data: Dictionary = all_saves[slot_id]
		print("Slot %d: %s - %s" % [
			slot_id, 
			save_data.get("level_name", "Unknown"), 
			save_data.get("playtime", "00:00:00")
		])
	print("========================")

func simulate_playtime_update(slot_id: int, additional_seconds: int) -> void:
	if not SaveManager.has_save(slot_id):
		print("Slot ", slot_id, " no existe")
		return
	
	var save_data := SaveManager.get_save_info(slot_id)
	var current_playtime: int = save_data.get("playtime_seconds", 0)
	var new_playtime := current_playtime + additional_seconds
	
	# Actualizar datos
	var updated_data := save_data.duplicate(true)
	updated_data["playtime_seconds"] = new_playtime
	
	SaveManager.save_game(slot_id, updated_data)
	print("Playtime actualizado en slot ", slot_id, ": +", additional_seconds, " segundos")
