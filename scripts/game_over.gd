extends Control

@onready var OptionsButton: Button = $HBoxContainer/OptionsButton
@onready var ContinueButton: Button = $HBoxContainer/ContinueButton
@onready var ExitButton: Button = $HBoxContainer/ExitButton
@onready var audiobutton: AudioStreamPlayer2D = $audiobutton
@onready var OptionPanel: Panel = $Panel
@onready var OptionsBack: Button = $Panel/VBoxContainer/BackButton
@onready var OptionsDiff: Button = $Panel/VBoxContainer/DifficultyButton
@onready var OptionsMusica: Button = $Panel/VBoxContainer/MusicButton
@export var button_ok: Resource
@export var button_change: Resource

var current_focused_button: Button = null
var bounce_tween: Tween = null
var first_focus : bool = true
var is_options_open: bool = false

func _ready():
	# Connect focus signals
	OptionsButton.focus_entered.connect(_on_button_focused.bind(OptionsButton))
	ExitButton.focus_entered.connect(_on_button_focused.bind(ExitButton))
	ContinueButton.focus_entered.connect(_on_button_focused.bind(ContinueButton))
	OptionsDiff.focus_entered.connect(_on_button_focused.bind(OptionsDiff))
	OptionsMusica.focus_entered.connect(_on_button_focused.bind(OptionsMusica))
	OptionsBack.focus_entered.connect(_on_button_focused.bind(OptionsBack))
	ContinueButton.grab_focus()
	# Set initial state (hidden, scaled down)
	OptionPanel.modulate.a = 0
	OptionPanel.scale = Vector2(0.9, 0.9)
	OptionPanel.visible = true
	
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
	bounce_tween.tween_property(current_focused_button, "position:y", original_y + 4, 0.2)
	bounce_tween.tween_property(current_focused_button, "position:y", original_y, 0.2)

func _on_TransitionAnimation_finished(animation_name: String):
	if animation_name == "Scene_Transition_in":
		get_tree().change_scene_to_file(GameManager.currentLevel)

func _on_exit_button_pressed() -> void:
	audiobutton.stream = button_ok
	audiobutton.play()
	await audiobutton.finished
	get_tree().quit()
	
func _grab_focus():
	ContinueButton.grab_focus()

func _on_continue_button_pressed() -> void:
	audiobutton.stream = button_ok
	audiobutton.play()
	var managers = get_tree().get_nodes_in_group("scene_manager")
	if managers.size() > 0 and managers[0].has_method("unpause_game"):
		managers[0].unpause_game()
	else:
		get_tree().paused = false

func _on_options_button_pressed() -> void:
	if is_options_open == true:
		return
	audiobutton.stream = button_ok
	audiobutton.play()
	
	# Make sure panel is visible before animating
	OptionPanel.visible = true
	OptionPanel.modulate.a = 0
	OptionPanel.scale = Vector2(0.9, 0.9)
	
	match GameManager.extra_time:
		0:
			OptionsDiff.text = "SIN ASISTENCIA"
		15:
			OptionsDiff.text = "+15 Segundos"
		30:
			OptionsDiff.text = "+30 Segundos"
		45:
			OptionsDiff.text = "+45 Segundos"
	match GameManager.music_on:
		true:
			OptionsMusica.text = "MÚSICA ON"
		false:
			OptionsMusica.text = "MÚSICA OFF"
	
	# Create show animation
	var show_tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	show_tween.tween_property(OptionPanel, "modulate:a", 1.0, 0.15)
	show_tween.parallel().tween_property(OptionPanel, "scale", Vector2(1.0, 1.0), 0.15)
	
	# Hide main buttons with fade
	var hide_tween = create_tween()
	hide_tween.tween_property($HBoxContainer, "modulate:a", 0.0, 0.1)
	hide_tween.tween_callback(func(): $HBoxContainer.visible = false)
	
	OptionsBack.grab_focus()
	is_options_open = true

func _on_back_button_pressed() -> void:
	audiobutton.stream = button_ok
	audiobutton.play()
	
	# First make sure HBoxContainer is visible but transparent
	$HBoxContainer.visible = true
	$HBoxContainer.modulate.a = 0
	$HBoxContainer.scale = Vector2(0.9, 0.9)
	
	# Hide options panel with fade
	var hide_tween = create_tween()
	hide_tween.tween_property(OptionPanel, "modulate:a", 0.0, 0.1)
	hide_tween.parallel().tween_property(OptionPanel, "scale", Vector2(0.9, 0.9), 0.1)
	# Don't set visible=false here - just let it stay hidden via alpha
	
	# Show pause menu buttons with pop-in effect
	var show_tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	show_tween.tween_property($HBoxContainer, "modulate:a", 1.0, 0.15)
	show_tween.parallel().tween_property($HBoxContainer, "scale", Vector2(1.0, 1.0), 0.15)
	
	first_focus = true
	# Set focus back to OptionsButton after animation
	show_tween.tween_callback(func(): OptionsButton.grab_focus())
	is_options_open = false


func _on_difficulty_button_pressed() -> void:
	audiobutton.stream = button_ok
	audiobutton.play()
	match GameManager.extra_time:
		0:
			GameManager.extra_time = 15
			OptionsDiff.text = "+15 Segundos"
		15:
			GameManager.extra_time = 30
			OptionsDiff.text = "+30 Segundos"
		30:
			GameManager.extra_time = 45
			OptionsDiff.text = "+45 Segundos"
		45:
			GameManager.extra_time = 0
			OptionsDiff.text = "SIN ASISTENCIA"

func _on_music_button_pressed() -> void:
	audiobutton.stream = button_ok
	audiobutton.play()
	if GameManager.music_on == true:
		GameManager.music_on = false
		OptionsMusica.text = "MÚSICA OFF"
		AudioServer.set_bus_mute(1, true)
		return
	if GameManager.music_on == false:
		GameManager.music_on = true
		OptionsMusica.text = "MÚSICA ON"
		AudioServer.set_bus_mute(1, false)
		return
