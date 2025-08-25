class_name MainMenu
extends Control

const ESCENA_AJUSTES := preload("res://scenes/ui/ventana_ajustes.tscn")

@onready var btn_ajustes: Button = %ajustes_btn

var ventana_ajustes: Window

func _ready() -> void:
	btn_ajustes.pressed.connect(_on_settings_pressed)

func _on_settings_pressed() -> void:
	if ventana_ajustes == null:
		ventana_ajustes = ESCENA_AJUSTES.instantiate()
		add_child(ventana_ajustes)
		ventana_ajustes.close_requested.connect(func(): ventana_ajustes.hide())
	ventana_ajustes.call("open_modal")
