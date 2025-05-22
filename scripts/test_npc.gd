extends Node2D

@export var dialogue_lines: Array[String] = []
@export var npc_portrait: Texture2D
@export var dialogue_manager: Node2D
@export var voice_sound: AudioStream
@export var sprite: Texture
@onready var sprite2D: Sprite2D = $Sprite2D

func _ready():
	sprite2D.texture = sprite
	print(sprite2D.texture)

func _on_area_2d_area_shape_entered(_area_rid: RID, area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	if area.is_in_group("weapon"):
		dialogue_manager.start_dialogue(
			dialogue_lines, 
			npc_portrait, 
			self, 
			voice_sound
		)
