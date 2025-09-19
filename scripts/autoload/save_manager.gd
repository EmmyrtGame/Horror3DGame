extends Node # AUTOLOAD | Save Game Manager

signal save_created(slot_id: int, save_data: Dictionary)
signal save_loaded(slot_id: int, save_data: Dictionary)
signal save_deleted(slot_id: int)
signal save_failder(slot_id: int, error: String)

const SAVES_PATH := "user://saves/"
const SAVE_EXTENSION := ".save"
const MAX_SAVE_SLOTS := 10
const SAVE_VERSION := 1

var saves_cache: Dictionary = {}

func _ready() -> void:
	_ensure_saves_directory()
	load_all_saves()

func _ensure_saves_directory() -> void:
	if not DirAccess.dir_exists_absolute(SAVES_PATH):
		DirAccess.open("user://").make_dir("saves")

func load_all_saves() -> void:
	saves_cache.clear()
	var dir := DirAccess.open(SAVES_PATH)
	if dir == null:
		return
	
	dir.list_dir_begin()
	var file_name := dir.get_next()
	
	while file_name != "":
		if file_name.ends_with(SAVE_EXTENSION):
			var slot_id := _extract_slot_id_from_filename(file_name)
			if slot_id >= 0:
				var save_data := _load_save_file(slot_id)
				if save_data.size() > 0:
					saves_cache[slot_id] = save_data
		file_name = dir.get_next()
	
	dir.list_dir_end()

func _extract_slot_id_from_filename(filename: String) -> int:
	var base_name := filename.get_basename()
	if base_name.begins_with("slot_"):
		return base_name.substr(5).to_int()
	return -1

func _load_save_file(slot_id: int) -> Dictionary:
	var file_path := _get_save_path(slot_id)
	var file := FileAccess.open(file_path, FileAccess.READ)
	
	if file == null:
		return {}
	
	var json_string := file.get_as_text()
	file.close()
	
	var json := JSON.new()
	var parse_result := json.parse(json_string)
	
	if parse_result != OK:
		return {}
	
	var save_data: Dictionary = json.data
	
	# Validar versión del guardado
	if not save_data.has("version") or save_data.version != SAVE_VERSION:
		return {}
	
	return save_data

func _get_save_path(slot_id: int) -> String:
	return SAVES_PATH + "slot_%d%s" % [slot_id, SAVE_EXTENSION]

func save_game(slot_id: int, game_data: Dictionary) -> bool:
	if slot_id < 0 or slot_id >= MAX_SAVE_SLOTS:
		emit_signal("save_failed", slot_id, "Invalid slot ID")
		return false
	
	var save_data := {
		"version": SAVE_VERSION,
		"slot_id": slot_id,
		"timestamp": Time.get_unix_time_from_system(),
		"playtime": _format_playtime(game_data.get("playtime_seconds", 0)),
		"level_name": game_data.get("level_name", "Unknown"),
		"player_data": game_data.get("player_data", {}),
		"game_state": game_data.get("game_state", {}),
		"screenshot_path": game_data.get("screenshot_path", "")
	}
	
	var file := FileAccess.open(_get_save_path(slot_id), FileAccess.WRITE)
	if file == null:
		emit_signal("save_failed", slot_id, "Could not create save file")
		return false
	
	var json_string := JSON.stringify(save_data)
	file.store_string(json_string)
	file.close()
	
	saves_cache[slot_id] = save_data
	emit_signal("save_created", slot_id, save_data)
	return true

func load_game(slot_id: int) -> Dictionary:
	if not has_save(slot_id):
		emit_signal("save_failed", slot_id, "Save slot does not exist")
		return {}
	
	var save_data : Dictionary = saves_cache[slot_id]
	emit_signal("save_loaded", slot_id, save_data)
	return save_data

func delete_save(slot_id: int) -> bool:
	if not has_save(slot_id):
		return false
	
	var file_path := _get_save_path(slot_id)
	if FileAccess.file_exists(file_path):
		DirAccess.remove_absolute(file_path)
	
	saves_cache.erase(slot_id)
	emit_signal("save_deleted", slot_id)
	return true

func has_save(slot_id: int) -> bool:
	return saves_cache.has(slot_id)

func get_save_info(slot_id: int) -> Dictionary:
	if has_save(slot_id):
		return saves_cache[slot_id]
	return {}

func get_all_saves() -> Dictionary:
	return saves_cache.duplicate()

func get_available_slot() -> int:
	for i in range(MAX_SAVE_SLOTS):
		if not has_save(i):
			return i
	return -1

func _format_playtime(seconds: int) -> String:
	var hours := seconds / 3600
	var minutes := (seconds % 3600) / 60
	var remaining_seconds := seconds % 60
	return "%02d:%02d:%02d" % [hours, minutes, remaining_seconds]


#------------------------------------------
# MÉTODOS DE TESTING - Solo para desarrollo
func create_demo_saves() -> void:
	print("Creando partidas de demo...")
	
	var demo_saves := [
		{
			"slot_id": 0,
			"level_name": "Abandoned Hospital - Floor 1",
			"playtime_seconds": 1800, # 30 minutos
			"player_data": {
				"position": Vector3(10.5, 0, -5.2),
				"health": 85,
				"stamina": 60,
				"inventory": ["flashlight", "key_red", "medical_kit"]
			},
			"game_state": {
				"current_chapter": 1,
				"completed_objectives": ["find_keycard", "unlock_main_door"],
				"unlocked_doors": ["door_01", "door_entrance"],
				"collected_documents": ["patient_file_001", "staff_memo_02"]
			}
		},
		{
			"slot_id": 2,
			"level_name": "Abandoned Hospital - Floor 2",
			"playtime_seconds": 4500, # 1 hora 15 minutos
			"player_data": {
				"position": Vector3(-8.0, 10, 12.3),
				"health": 45,
				"stamina": 30,
				"inventory": ["flashlight", "key_red", "key_blue", "medical_kit", "batteries"]
			},
			"game_state": {
				"current_chapter": 2,
				"completed_objectives": ["find_keycard", "unlock_main_door", "reach_second_floor"],
				"unlocked_doors": ["door_01", "door_entrance", "door_02", "elevator"],
				"collected_documents": ["patient_file_001", "staff_memo_02", "security_log"]
			}
		},
		{
			"slot_id": 5,
			"level_name": "Underground Tunnels",
			"playtime_seconds": 8100, # 2 horas 15 minutos
			"player_data": {
				"position": Vector3(25.1, -5, 8.7),
				"health": 70,
				"stamina": 80,
				"inventory": ["flashlight", "key_master", "medical_kit", "rope", "crowbar"]
			},
			"game_state": {
				"current_chapter": 4,
				"completed_objectives": [
					"find_keycard", "unlock_main_door", "reach_second_floor", 
					"escape_hospital", "enter_tunnels"
				],
				"unlocked_doors": ["door_01", "door_entrance", "door_02", "elevator", "tunnel_gate"],
				"collected_documents": [
					"patient_file_001", "staff_memo_02", "security_log", 
					"tunnel_blueprint", "escape_plan"
				]
			}
		}
	]
	
	for save_data in demo_saves:
		var success := save_game(save_data.slot_id, save_data)
		if success:
			print("Demo save creado en slot ", save_data.slot_id)
		else:
			print("Error creando demo save en slot ", save_data.slot_id)

func clear_all_saves() -> void:
	print("Eliminando todas las partidas...")
	for slot_id in saves_cache.keys():
		delete_save(slot_id)
	print("Todas las partidas eliminadas")

func create_new_game_save(slot_id: int = -1) -> int:
	if slot_id < 0:
		slot_id = get_available_slot()
	
	if slot_id < 0:
		print("No hay slots disponibles")
		return -1
	
	var new_game_data := {
		"level_name": "Hospital Entrance",
		"playtime_seconds": 0,
		"player_data": {
			"position": Vector3(0, 0, 0),
			"health": 100,
			"stamina": 100,
			"inventory": ["flashlight"]
		},
		"game_state": {
			"current_chapter": 0,
			"completed_objectives": [],
			"unlocked_doors": [],
			"collected_documents": []
		}
	}
	
	var success := save_game(slot_id, new_game_data)
	if success:
		print("Nueva partida creada en slot ", slot_id)
		return slot_id
	else:
		print("Error creando nueva partida")
		return -1
#------------------------------------------
