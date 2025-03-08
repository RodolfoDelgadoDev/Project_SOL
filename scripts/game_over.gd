extends Control

@onready var SceneTransition: CanvasLayer = $Scene_Transition
@onready var animation_player: AnimationPlayer = $Scene_Transition/AnimationPlayer 
@onready var RestartButton: Button = $RestartButton
@onready var ExitButton: Button = $ExitButton

func _ready():
	animation_player.animation_finished.connect(_on_TransitionAnimation_finished)
	RestartButton.visible = false
	$ExitButton.visible = false
	await get_tree().create_timer(5.1).timeout
	RestartButton.visible = true
	await get_tree().create_timer(0.5).timeout
	$ExitButton.visible = true
	pass
	

# Function to handle the scene change after the animation finishes
func _on_TransitionAnimation_finished(animation_name: String):
	if animation_name == "Scene_Transition_in":  # Check if the finished animation is the one we want
		get_tree().change_scene_to_file(GameManager.currentLevel)


func _on_restart_button_pressed() -> void:
	animation_player.play("Scene_Transition_in")  # Start the transition animation


func _on_exit_button_pressed() -> void:
	get_tree().quit()
