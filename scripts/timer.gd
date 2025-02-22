extends Node2D

var segundos = GameManager.Segundos
@onready var label: Label = $Label
@onready var timer: Timer = $Timer

func _ready() -> void:
	updateText()
	
func _process(_delta: float) -> void:
	updateText()
	if GameManager.Segundos <= 0:
		var parent = get_parent()
		var grandparent = parent.get_parent()
		grandparent.change_scene("res://scenes/GameOver.tscn")

func _on_timer_timeout() -> void:
	GameManager.Segundos -=1

func updateText() -> void:
	label.text = str(GameManager.Segundos)
