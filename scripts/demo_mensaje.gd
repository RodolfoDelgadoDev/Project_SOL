extends Control

@onready var ColorFade : ColorRect = $ColorFade

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Pause"):
		# Create fade animation
		ColorFade.modulate.a = 0
		ColorFade.visible = true
		var fade_tween = create_tween()
		fade_tween.tween_property(ColorFade, "modulate:a", 1, 3)
		fade_tween.tween_callback(func(): 
			get_tree().quit()  # Quit after fade completes
		)
