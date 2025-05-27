extends Control

@onready var OptionsButton: Button = $HBoxContainer/OptionsButton
@onready var ContinueButton: Button = $HBoxContainer/ContinueButton
@onready var ExitButton: Button = $HBoxContainer/ExitButton
@onready var audiobutton: AudioStreamPlayer2D = $audiobutton
@export var button_ok: Resource
@export var button_change: Resource

var current_focused_button: Button = null
var bounce_tween: Tween = null
var first_focus : bool = true

func _ready():
	# Connect focus signals
	OptionsButton.focus_entered.connect(_on_button_focused.bind(OptionsButton))
	ExitButton.focus_entered.connect(_on_button_focused.bind(ExitButton))
	ContinueButton.focus_entered.connect(_on_button_focused.bind(ContinueButton))

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
	bounce_tween.tween_property(current_focused_button, "position:y", original_y - 2, 0.2)
	bounce_tween.tween_property(current_focused_button, "position:y", original_y, 0.2)
	bounce_tween.tween_property(current_focused_button, "position:y", original_y + 2, 0.2)
	bounce_tween.tween_property(current_focused_button, "position:y", original_y, 0.2)

func _on_TransitionAnimation_finished(animation_name: String):
	if animation_name == "Scene_Transition_in":
		get_tree().change_scene_to_file(GameManager.currentLevel)

func _on_restart_button_pressed() -> void:
	audiobutton.stream = button_ok
	audiobutton.play()

func _on_exit_button_pressed() -> void:
	audiobutton.stream = button_ok
	audiobutton.play()
	await audiobutton.finished
	get_tree().quit()
