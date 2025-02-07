extends Node2D

@export var minutos: int = 1
var segundos: int
@onready var label: Label = $Label
@onready var timer: Timer = $Timer

func _ready() -> void:
	segundos = minutos * 60
	updateText()

func _on_timer_timeout() -> void:
	if segundos > 0:
		segundos -= 1
		updateText()
	else:
		timer.stop() #cambiar esto por lógica de game over
		get_tree().change_scene_to_file("res://Scenes/GameOver.tscn")

func updateText() -> void:
	label.text = str(segundos)
