extends Control

@onready var SceneTransition: CanvasLayer = $Scene_Transition
@onready var animation_player: AnimationPlayer = $Scene_Transition/AnimationPlayer 
@onready var audiobutton: AudioStreamPlayer2D = $audiobutton
@export var button_ok: Resource
@export var button_change: Resource

@export var newGameButton : Button
@export var ContinueButton : Button
@export var TutorialButton : Button
@export var ExitButton : Button

@export var current_lvl : PackedScene
@export var current_bottles : int 
var Tutorial = false
var continue_game : bool = false
var current_focused_button: Button = null
var bounce_tween: Tween = null
var first_focus : bool = true
var has_save = GameManager.save_file_exists()

func _ready():
	# El botón de continuar solo se muestra si hay una partida guardada
	ContinueButton.visible = has_save
	if not has_save:
		print("No se encontró partida")
	# Connect the button signals
	newGameButton.pressed.connect(_on_NewGameButton_pressed)
	ContinueButton.pressed.connect(_on_ContinueButton_pressed)
	ExitButton.pressed.connect(_on_Exitbutton_pressed)
	TutorialButton.pressed.connect(_on_TutorialButton_pressed)
	animation_player.animation_finished.connect(_on_TransitionAnimation_finished)
	# Connect focus signals
	newGameButton.focus_entered.connect(_on_button_focused.bind(newGameButton))
	ContinueButton.focus_entered.connect(_on_button_focused.bind(ContinueButton))
	ExitButton.focus_entered.connect(_on_button_focused.bind(ExitButton))
	TutorialButton.focus_entered.connect(_on_button_focused.bind(TutorialButton))
	if has_save:
		ContinueButton.grab_focus()
	else:
		TutorialButton.grab_focus()

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
	

func _on_NewGameButton_pressed():
	continue_game = false
	_start_transition()

func _on_ContinueButton_pressed():
	continue_game = true
	_start_transition()

func _start_transition():
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
			return
		if continue_game:
			# Cargamos levelNumber/plasticoin y volvemos al último descanso
			GameManager.load_game()
			get_tree().change_scene_to_file(GameManager.get_descanso_scene())
		else:
			GameManager.levelNumber = 1
			GameManager.plasticoin = 1
			get_tree().change_scene_to_file("res://Scenes/Levels/Descansos/descanso1.tscn")
			
func chooseTargetScene():
	var targetScene : String
	match GameManager.levelNumber:
			1:
				targetScene = "res://Scenes/Levels/edificio.tscn"
			2:
				targetScene = "res://Scenes/Levels/edificio2.tscn"
			3:
				targetScene = "res://Scenes/Levels/edificio3.tscn"
			4:
				targetScene = "res://Scenes/Levels/complejo.tscn"
			5:
				targetScene = "res://Scenes/Levels/complejo2.tscn"
			6:
				targetScene = "res://Scenes/Levels/bosque.tscn"
			7:
				targetScene = "res://Scenes/Levels/bosque2.tscn"
			8:
				targetScene = "res://Scenes/Levels/Bossfight.tscn"
			_:
				targetScene = "res://Scenes/Levels/edificio.tscn"
				printerr("Unexpected level number, defaulting to level 1")
	print("Current level number: ", GameManager.levelNumber)
	return targetScene
