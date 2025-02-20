extends Control

func _ready():
	# Conecta la señal "pressed" del botón a una función
	$RestartButton.pressed.connect(_on_Restartbutton_pressed)
	$ExitButton.pressed.connect(_on_Exitbutton_pressed)
	

func _on_Restartbutton_pressed():
	# Reinicia el juego o carga la escena principal
	GameManager.Segundos = 30
	get_tree().change_scene_to_file("res://scenes/edificio.tscn")

func _on_Exitbutton_pressed():
	get_tree().quit()
