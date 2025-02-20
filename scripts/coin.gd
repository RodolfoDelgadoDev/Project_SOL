extends Node2D

@export var recuperacion = 5


func _on_area_2d_area_shape_entered(_area_rid: RID, area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	if area.is_in_group("player"):
		GameManager.Segundos += recuperacion
		get_parent().addBottle()
		queue_free()
