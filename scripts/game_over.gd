extends Control

func _ready():
	# Conecta la señal "pressed" del botón a una función
	$RestartButton.pressed.connect(_on_button_pressed)# Ajusta el tamaño de la UI al tamaño de la pantalla

	

func _on_button_pressed():
	# Reinicia el juego o carga la escena principal
	GameManager.Segundos = 30
	get_tree().change_scene_to_file("res://scenes/main.tscn")
