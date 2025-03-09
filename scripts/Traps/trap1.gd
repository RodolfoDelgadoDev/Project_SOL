extends Node2D

@export var damage: int
@export var attackSFX: AudioStream
@export var destroySFX: AudioStream
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var sprite: AnimatedSprite2D = $Area2D/AnimatedSprite2D
@onready var collision: CollisionShape2D = $Area2D/CollisionShape2D

func _on_area_2d_area_shape_entered(_area_rid: RID, area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
		if area.is_in_group("weapon"):
			audio_player.stream = destroySFX
			audio_player.play()  # Play attack sound
			collision.disabled = true
			sprite.visible = false
			#await audio_player.finished
			queue_free()
			
		if area.is_in_group("player"):
			audio_player.stream = attackSFX
			audio_player.play()  # Play attack sound
			GameManager.takeDamage(damage)
			collision.disabled = true
			sprite.visible = false
			#await audio_player.finished
			queue_free()
