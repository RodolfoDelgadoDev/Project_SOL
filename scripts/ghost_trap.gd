extends Node2D

# Exported variables
@export var lights: Node2D
@export var BGM: AudioStreamPlayer2D
@export var enemy: Node2D  # The enemy node to move

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		# Turn on the visibility of the lights
		lights.visible = true

		# Play the audio
		BGM.play()

		# Move the enemy to the target position
		enemy.visible = true
		enemy.quieto = false
		
		var SceneManager = get_parent()
		SceneManager.segundos = 60
		print (SceneManager.segundos)

		# Destroy this node
		queue_free()
