extends Node2D

var reached_goal : bool = false

func _process(_delta: float) -> void:
	if reached_goal == true:
		var parent = get_parent()
		if parent.is_typewriter_active == false:
			parent.change_scene("res://scenes/MainMenu.tscn")
	
func _on_area_2d_area_shape_entered(_area_rid: RID, area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	if area.is_in_group("player"):
		var parent = get_parent()
		if parent.descanso == true:
			pass
		else:
			# Get the parent node and check if allBottles is true
			if parent.has_method("get") and parent.get("allBottles"):
				parent.start_typewriter("Encontraste todas las botellas!")
			else:
				parent.start_typewriter("Te faltaron algunas botellas!")
		reached_goal = true
	
