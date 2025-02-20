extends Node2D

var dialNum : int = 0

func _on_area_2d_area_shape_entered(_area_rid: RID, area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	if area.is_in_group("weapon"):
		# Get the parent node and check if allBottles is true
		var parent = get_parent()
		if dialNum == 0:
			parent.start_typewriter("¡Qué ganas de comer un alfajor...!")
			dialNum += 1
		else:
			parent.start_typewriter("¡La salida está a tu izquierda!")
