extends CharacterBody2D

var activated : bool = false

func _physics_process(delta: float) -> void:
	if GameManager.ninja_boss == 3 and activated == false:
		activated = true
		print("ninjas derrotados, destruyendo cubo de hielo!")
		queue_free()
