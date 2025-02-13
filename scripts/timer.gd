extends Node2D

var segundos = GameManager.Segundos
@onready var label: Label = $Label
@onready var timer: Timer = $Timer

func _ready() -> void:
	updateText()
	
func _process(_delta: float) -> void:
	updateText()
	if GameManager.Segundos <= 0:
		get_tree().change_scene_to_file("res://scenes/GameOver.tscn")

func _on_timer_timeout() -> void:
	GameManager.Segundos -=1

func updateText() -> void:
	label.text = str(GameManager.Segundos)
