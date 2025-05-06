extends Node2D

var dialNum : int = 0
@export var npc_portrait: Texture  # Ensure this is declared as Texture

func _on_area_2d_area_shape_entered(_area_rid: RID, area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	if area.is_in_group("weapon"):
		var parent = get_parent()
		if dialNum != 0:
			parent.show_dialogue("Lo voy a explicar solo una vez...")
		else:
			parent.show_dialogue("Tarde en tu primer día!?")
			dialNum += 1
