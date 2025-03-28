extends Node2D

var reached_goal : bool = false
@export var has_npc : bool = true
@export var npc_portrait: Texture  # Ensure this is declared as Texture
@export var animated_sprite: AnimatedSprite2D
var goalAnimacion: bool = true
var finish_goal: bool = false

func _process(_delta: float) -> void:
	if reached_goal == true:
		if has_npc == true:
			# Para que se reproduzca una vez y no en loop cada vez que termina
			if goalAnimacion == true:
				animated_sprite.play("Open")
				goalAnimacion = false
		var SceneManager = get_parent()
		if SceneManager.is_typewriter_active == false && finish_goal == false:
			finish_goal = true
			GameManager.reachedGoal(false)
			if SceneManager.descanso == false:
				GameManager.levelNumber = GameManager.levelNumber + 1
				print("Level number:")
				print(GameManager.levelNumber)
			SceneManager.change_scene()
			return
	
func _on_area_2d_area_shape_entered(_area_rid: RID, area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	if area.is_in_group("player") and goalAnimacion == true:
		GameManager.reachedGoal(true)
		var SceneManager = get_parent()
		SceneManager.stop_timer()
		if SceneManager.descanso == true:
			pass
		else:
			# Get the parent node and check if allBottles is true
			if SceneManager.has_method("get") and SceneManager.get("allBottles"):
				SceneManager.start_typewriter("Encontraste todas las botellas!", npc_portrait)
			else:
				SceneManager.start_typewriter("Te faltaron algunas botellas!", npc_portrait)
		reached_goal = true
	
