extends Node2D

@export var damage: int


func _on_area_2d_area_shape_entered(_area_rid: RID, _area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	GameManager.takeDamage(damage)
	print(GameManager.Segundos)
	
