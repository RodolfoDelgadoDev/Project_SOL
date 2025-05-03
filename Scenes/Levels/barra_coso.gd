extends Node2D

@export var barra: ColorRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_area_2d_area_entered(_area: Area2D) -> void:
	barra.appear()
	print("funca")
	queue_free()
