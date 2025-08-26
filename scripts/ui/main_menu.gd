class_name MainMenu
extends Control

const ESCENA_AJUSTES := preload("res://scenes/ui/ventana_ajustes.tscn")

@onready var btn_ajustes: Button = %ajustes_btn

var ventana_ajustes: Window

func _on_ajustes_btn_pressed() -> void:
	if ventana_ajustes == null:
		ventana_ajustes = ESCENA_AJUSTES.instantiate()
		add_child(ventana_ajustes)
	ventana_ajustes.call("open_modal")


func _on_salir_btn_pressed() -> void:
	get_tree().quit()
