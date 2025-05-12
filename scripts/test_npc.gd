extends Node2D

var dialNum : int = 0
@export var npc_portrait: Texture  # Ensure this is declared as Texture
@export var dialogue_lines: PackedStringArray = []  # Array of dialogue lines for the NPC

func _on_area_2d_area_shape_entered(_area_rid: RID, area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	if area.is_in_group("weapon"):
		var parent = get_parent()
		if dialNum < dialogue_lines.size():  # Check if there are more dialogue lines
			parent.show_dialogue(dialogue_lines[dialNum])
			dialNum += 1
		else:
			# If all dialogue lines are exhausted, reset to first line
			dialNum = 0  # Reset dialogue counter (optional)
			parent.show_dialogue(dialogue_lines[dialNum])
