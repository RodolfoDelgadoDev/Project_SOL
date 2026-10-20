extends Node2D

@onready var healthbar : TextureProgressBar = $TextureProgressBar
@export var boss : CharacterBody2D

var original_x_position: float # Para almacenar la posición X original de la barra de vida

# Propiedades para la animación de sacudida en pull_out
var shake_amplitude: float = 5.0 # Amplitud del movimiento de sacudida en X
var shake_duration_per_oscillation: float = 0.05 # Duración de cada oscilación de sacudida
var shake_loops_during_pull_out: int = 20 # Número de sacudidas durante el movimiento de pull_out

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Almacenar la posición X inicial de este nodo (el Node2D principal) desde el editor
	original_x_position = self.position.x
	
	# Mover este nodo (el Node2D principal) 200px a la derecha instantáneamente al inicio,
	# asumiendo que esta es su posición "fuera de pantalla" o inicial visible.
	self.position.x = original_x_position + 200
	
	# Configurar el valor máximo y actual de la barra de vida
	if boss:
		healthbar.max_value = boss.health
		healthbar.value = boss.health
	else:
		printerr("Boss node not assigned to Healthbar script!")

func damage():
	# Actualizar el valor de la barra de vida cuando el jefe recibe daño
	if boss:
		healthbar.value = boss.health

func pull_in():
	# Mueve este nodo (el Node2D principal) 200px a la izquierda (hacia la posición original) con un tween
	
	# Detener cualquier tween existente en este nodo para evitar conflictos
	#if self.has_method("stop_all_tweens"): # Godot 4+ has this method for Node2D
		#self.stop_all_tweens()
	
	var pull_in_tween = create_tween()
	pull_in_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	# Mover este nodo a su posición X original (200px a la izquierda desde donde está)
	pull_in_tween.tween_property(self, "position:x", original_x_position, 0.5) # Duración de 0.5 segundos

func pull_out():
	# Se sacude un montón y mueve este nodo (el Node2D principal) lentamente 200px a la derecha (fuera de pantalla)
	
	# Detener cualquier tween existente en este nodo
	#if self.has_method("stop_all_tweens"):
		#self.stop_all_tweens()
	
	# Tween principal para el movimiento lento hacia la derecha de este nodo
	var main_move_tween = create_tween()
	main_move_tween.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	# Mover este nodo 200px a la derecha desde su posición actual
	main_move_tween.tween_property(self, "position:y", original_x_position + 100, 5) # Duración de 1.5 segundos (lento)
	var rocking_rotation_tween = create_tween()
	var rotation_amplitude: float = 1.0 # Grados para la rotación de balanceo en estado vulnerable
	var rocking_rotation_duration: float = 0.2
	rocking_rotation_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	rocking_rotation_tween.tween_property(self, "rotation_degrees", rotation_amplitude, rocking_rotation_duration) # Rotar a la derecha
	rocking_rotation_tween.tween_property(self, "rotation_degrees", -rotation_amplitude, rocking_rotation_duration * 2) # Rotar a la izquierda
	rocking_rotation_tween.tween_property(self, "rotation_degrees", 0.0, rocking_rotation_duration) # Volver al ángulo original
	rocking_rotation_tween.set_loops()
