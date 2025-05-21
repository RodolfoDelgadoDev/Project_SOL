extends Node2D

@export var recuperacion = 5
@export var grabSFX: AudioStream
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var sprite : Sprite2D = $Sprite2D
var activated : bool = false

func _on_area_2d_area_shape_entered(_area_rid: RID, area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	if area.is_in_group("player"):
		if activated == false:
				activated = true
				audio_player.stream = grabSFX
				audio_player.play()  # Play attack sound
				GameManager.Segundos += recuperacion
				get_parent().addBottle()
				sprite.visible = false
				await audio_player.finished
				queue_free()
