extends Node2D

var dialNum : int = 0
@export var npc_portrait: Texture
@export var dialogue_lines : Array[String] = [
	"Tarde en tu primer día!?",
	"Lo voy a explicar solo una vez..."
	# Add more lines as needed
]

func _on_area_2d_area_shape_entered(_area_rid: RID, area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	if area.is_in_group("weapon") and dialNum < dialogue_lines.size():
		get_parent().show_dialogue(dialogue_lines[dialNum])
		dialNum += 1
