extends Node2D

var segundos = GameManager.Segundos
@onready var label: Label = $Label
@onready var timer: Timer = $Timer

func _ready() -> void:
	updateText()

func _on_timer_timeout() -> void:
	if segundos > 0:
		segundos -= 1
		GameManager.Segundos -=1
		updateText()
	else:
		timer.stop() #cambiar esto por lógica de game over

func updateText() -> void:
	label.text = str(segundos)
