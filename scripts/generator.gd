extends Node2D

@export var health = 30
@export var attackSFX: AudioStream
@export var destroySFX: AudioStream

# para agarrar al boss
@export var boss1: CharacterBody2D
@export var boss2: CharacterBody2D

@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var sprite: Sprite2D = $Sprite2D2
@onready var area2D: Area2D = $Area2D


var destroyed : bool = false
# Called when the node enters the scene tree for the first time.



func _on_area_2d_area_entered(area: Area2D) -> void:
		if area.is_in_group("weapon"):
			if destroyed == false:
				health -= GameManager.playerDamage
				print (health)
				if health >= 0:
					destroy()
					audio_player.play()  # Play attack sound
				else:
					destroy()
				
func destroy():
	if health <= 0:
		destroyed = true
		area2D.set_collision_mask_value(4, false)
		audio_player.stream = destroySFX
		await audio_player.finished
		boss1.on_destroy_gen()
		boss2.on_destroy_gen()
		queue_free()
		
	else:
		audio_player.stream = attackSFX
