extends Node2D

# Array of dialogue sets for each level (1-8)
@export var dialogue_lines1: Array[String] = []
@export var dialogue_lines2: Array[String] = []
@export var dialogue_lines3: Array[String] = []
@export var dialogue_lines4: Array[String] = []
@export var dialogue_lines5: Array[String] = []
@export var dialogue_lines6: Array[String] = []
@export var dialogue_lines7: Array[String] = []
@export var dialogue_lines8: Array[String] = []

@export var npc_portrait: Texture2D
@export var dialogue_manager: Node2D
@export var voice_sound: AudioStream
@export var sprite: Texture
@onready var sprite2D: Sprite2D = $Sprite2D

func _ready():
	sprite2D.texture = sprite

func get_dialogue_for_current_level() -> Array[String]:
	match GameManager.levelNumber:
		1: return dialogue_lines1
		2: return dialogue_lines2
		3: return dialogue_lines3
		4: return dialogue_lines4
		5: return dialogue_lines5
		6: return dialogue_lines6
		7: return dialogue_lines7
		8: return dialogue_lines8
		_: return dialogue_lines1  # Default fallback

func _on_area_2d_area_shape_entered(_area_rid: RID, area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	if area.is_in_group("weapon"):
		var current_dialogue = get_dialogue_for_current_level()
		if current_dialogue.size() > 0:  # Only start if there's dialogue
			dialogue_manager.start_dialogue(
				current_dialogue, 
				npc_portrait, 
				self, 
				voice_sound
			)
