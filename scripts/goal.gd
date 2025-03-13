extends Node2D

var reached_goal : bool = false
@export var npc_portrait: Texture  # Ensure this is declared as Texture
@export var animated_sprite: AnimatedSprite2D
var goalAnimacion: bool = true

func _process(_delta: float) -> void:
	if reached_goal == true:
		# Para que se reproduzca una vez y no en loop cada vez que termina
		if goalAnimacion == true:
			animated_sprite.play("Open")
			goalAnimacion = false
		var SceneManager = get_parent()
		if SceneManager.is_typewriter_active == false:
			GameManager.reachedGoal(false)
			SceneManager.change_scene("res://Scenes/Levels/descanso.tscn")
	
func _on_area_2d_area_shape_entered(_area_rid: RID, area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	if area.is_in_group("player") and goalAnimacion == true:
		GameManager.reachedGoal(true)
		var SceneManager = get_parent()
		SceneManager.stop_timer()
		if SceneManager.descanso == true:
			pass #mandar a otra escena
		else:
			# Get the parent node and check if allBottles is true
			if SceneManager.has_method("get") and SceneManager.get("allBottles"):
				SceneManager.start_typewriter("Encontraste todas las botellas!", npc_portrait)
			else:
				SceneManager.start_typewriter("Te faltaron algunas botellas!", npc_portrait)
		reached_goal = true
	
