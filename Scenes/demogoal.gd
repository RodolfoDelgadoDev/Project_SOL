extends Node2D

var reached_goal : bool = false
@export var has_npc : bool = true
@export var npc_portrait: Texture  # Ensure this is declared as Texture
@export var animated_sprite: AnimatedSprite2D
var goalAnimacion: bool = true
var finish_goal: bool = false
	
func _on_area_2d_area_shape_entered(_area_rid: RID, area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	if area.is_in_group("player"):
		var SceneManager = get_parent()
		SceneManager.forced_change_scene()
