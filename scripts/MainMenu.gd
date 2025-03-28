extends Control

@onready var SceneTransition: CanvasLayer = $Scene_Transition
@onready var animation_player: AnimationPlayer = $Scene_Transition/AnimationPlayer 
var Tutorial = false

func _ready():
	# Connect the button signals
	$RestartButton.pressed.connect(_on_Restartbutton_pressed)
	$ExitButton.pressed.connect(_on_Exitbutton_pressed)
	$TutorialButton.pressed.connect(_on_TutorialButton_pressed)
	animation_player.animation_finished.connect(_on_TransitionAnimation_finished)

func _on_Restartbutton_pressed():
	animation_player.play("Scene_Transition_in")  # Start the transition animation

func _on_TutorialButton_pressed():
	animation_player.play("Scene_Transition_in")  # Start the transition animation
	Tutorial = true

func _on_Exitbutton_pressed():
	get_tree().quit()

# Function to handle the scene change after the animation finishes
func _on_TransitionAnimation_finished(animation_name: String):
	if animation_name == "Scene_Transition_in":  # Check if the finished animation is the one we want
		if Tutorial == true:
			get_tree().change_scene_to_file("res://Scenes/Levels/pasillo.tscn")
		else:
			GameManager.levelNumber +=1
			print(GameManager.currentLevel)
			get_tree().change_scene_to_file("res://Scenes/Levels/descanso.tscn")
