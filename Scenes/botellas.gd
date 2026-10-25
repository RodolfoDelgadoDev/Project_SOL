extends Control

@export var botellas : Button
@export var audiopla : AudioStreamPlayer2D

func ready():
	botellas.grab_focus()
	

func _on_exit_button_pressed() -> void:
	audiopla.play()
	await audiopla.finished
	get_tree().change_scene_to_file("res://Scenes/MainMenuUpdate.tscn")
