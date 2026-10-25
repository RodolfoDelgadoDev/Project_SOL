extends Node2D
@export var exit : Button

func _ready() -> void:
	exit.grab_focus()
	
func _on_exit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenuUpdate.tscn")
