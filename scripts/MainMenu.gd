extends Control

@onready var SceneTransition: CanvasLayer = $Scene_Transition
@onready var animation_player: AnimationPlayer = $Scene_Transition/AnimationPlayer 
@onready var audiobutton: AudioStreamPlayer2D = $audiobutton
@onready var DemoText: Label = $Gameovertext/DemoText
@export var button_ok: Resource
@export var button_change: Resource
var Tutorial = false
var current_focused_button: Button = null
var bounce_tween: Tween = null
var first_focus : bool = true

func _ready():
	# Connect the button signals
	$RestartButton.pressed.connect(_on_Restartbutton_pressed)
	$ExitButton.pressed.connect(_on_Exitbutton_pressed)
	$TutorialButton.pressed.connect(_on_TutorialButton_pressed)
	animation_player.animation_finished.connect(_on_TransitionAnimation_finished)
	# Connect focus signals
	$RestartButton.focus_entered.connect(_on_button_focused.bind($RestartButton))
	$ExitButton.focus_entered.connect(_on_button_focused.bind($ExitButton))
	$TutorialButton.focus_entered.connect(_on_button_focused.bind($TutorialButton))
	$TutorialButton.grab_focus()
	var original_y = DemoText.position.y
	
	# Create bounce effect
	bounce_tween = create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	bounce_tween.tween_property(DemoText, "position:y", original_y - 2, 1)
	bounce_tween.tween_property(DemoText, "position:y", original_y, 0.6)
	bounce_tween.tween_property(DemoText, "position:y", original_y + 4, 1)
	bounce_tween.tween_property(DemoText, "position:y", original_y, 0.6)

func _on_button_focused(button: Button):
	# Stop any existing bounce animation
	if bounce_tween:
		bounce_tween.kill()
	
	current_focused_button = button
	_start_bounce_animation()
	if first_focus == true:
		first_focus = false
		return
	audiobutton.stream = button_change
	audiobutton.play()

func _start_bounce_animation():
	if not current_focused_button:
		return
	
	# Store original position
	var original_y = current_focused_button.position.y
	
	# Create bounce effect
	bounce_tween = create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	bounce_tween.tween_property(current_focused_button, "position:y", original_y - 1, 0.2)
	bounce_tween.tween_property(current_focused_button, "position:y", original_y, 0.2)
	bounce_tween.tween_property(current_focused_button, "position:y", original_y + 1, 0.2)
	bounce_tween.tween_property(current_focused_button, "position:y", original_y, 0.2)
	

func _on_Restartbutton_pressed():
	animation_player.play("Scene_Transition_in")  # Start the transition animation
	audiobutton.stream = button_ok
	audiobutton.play()

func _on_TutorialButton_pressed():
	animation_player.play("Scene_Transition_in")  # Start the transition animation
	Tutorial = true
	audiobutton.stream = button_ok
	audiobutton.play()

func _on_Exitbutton_pressed():
	audiobutton.stream = button_ok
	audiobutton.play()
	await audiobutton.finished
	get_tree().quit()

# Function to handle the scene change after the animation finishes
func _on_TransitionAnimation_finished(animation_name: String):
	if animation_name == "Scene_Transition_in":  # Check if the finished animation is the one we want
		if Tutorial == true:
			get_tree().change_scene_to_file("res://Scenes/Levels/Tutorial.tscn")
		else:
			GameManager.levelNumber = 1
			GameManager.plasticoin +=1
			print(GameManager.currentLevel)
			get_tree().change_scene_to_file("res://Scenes/Levels/Descansos/descanso1.tscn")
