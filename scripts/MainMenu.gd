extends Control

@onready var SceneTransition: CanvasLayer = $Scene_Transition
@onready var animation_player: AnimationPlayer = $Scene_Transition/AnimationPlayer  # Assuming you have an AnimationPlayer

func _ready():
	SceneTransition.visible = true
	# Connect the button signals
	$RestartButton.pressed.connect(_on_Restartbutton_pressed)
	$ExitButton.pressed.connect(_on_Exitbutton_pressed)
	animation_player.animation_finished.connect(_on_TransitionAnimation_finished)

func _on_Restartbutton_pressed():
	animation_player.play("Scene_Transition_in")  # Start the transition animation

func _on_Exitbutton_pressed():
	get_tree().quit()

# Function to handle the scene change after the animation finishes
func _on_TransitionAnimation_finished(animation_name: String):
	if animation_name == "Scene_Transition_in":  # Check if the finished animation is the one we want
		get_tree().change_scene_to_file("res://Scenes/edificio.tscn")
