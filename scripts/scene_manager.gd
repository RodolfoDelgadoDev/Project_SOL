extends Node2D

# Este nodo maneja los elementos de la escena, el timer, cuantas botellas hay, etc.
@export var segundos: int
@export var descanso: bool # if true = indica que estás en la sala de descanso
@export var targetScene: NodePath
@onready var dialogue_box: TextureRect = $CanvasLayer/DialogueBox/ColorRect
@onready var dialogue_label: Label = $CanvasLayer/DialogueBox/ColorRect/TextEdit
@onready var portrait_texture: TextureRect = $CanvasLayer/DialogueBox/ColorRect/Portrait
@onready var timer: Node2D = $CanvasLayer/Timer
@onready var SceneTransition: CanvasLayer = $Scene_Transition
@onready var animation_player: AnimationPlayer = $Scene_Transition/AnimationPlayer  # Assuming you have an AnimationPlayer

@export var sec1: Node2D
@export var sec2: Node2D
@export var sec3: Node2D
@export var sec4: Node2D
@export var sec5: Node2D
@export var sec6: Node2D
@export var hide_visuals: Node2D

var bottleNum: int = 0
var bottleTotal: int
var allBottles: bool = false

var current_dialogue: String = ""
var typing_speed: float = 0.05  # seconds per character
var is_typing: bool = false
var skip_requested: bool = false

# Typewriter effect variables
var typewriter_text: String = ""
var typewriter_index: int = 0
@export var typewriter_delay: float = 0.05  # Delay between each letter
var is_typewriter_active: bool = false

# Cursor variables
var cursor_visible: bool = false
@export var cursor_blink_delay: float = 0.5  # Delay for cursor blinking
var cursor_timer: Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#GameManager.descanso = descanso
	var current_scene = get_tree().current_scene.scene_file_path
	GameManager.currentLevel = current_scene
	print(current_scene)
	GameManager.Segundos = segundos
	for child in get_children():
		if child.is_in_group("pickup"):
			bottleTotal += 1
	print("Total bottles found: ", bottleTotal)
	if descanso:
		timer.stop_timer()
		toggle_timer()
		reciclaje()
	dialogue_box.visible = false
	# Start with dialogue hidden

func show_dialogue(text: String, portrait: Texture = null) -> void:
	if dialogue_box.visible == true:
		return
	if is_typing:
		skip_requested = true
		return
	
	dialogue_box.visible = true
	current_dialogue = text
	dialogue_label.text = ""
	
	if portrait:
		portrait_texture.texture = portrait
		portrait_texture.visible = true
	else:
		portrait_texture.visible = false
	
	is_typing = true
	skip_requested = false
	_start_typing()
	
func _start_typing() -> void:
	var current_length = dialogue_label.text.length()
	
	if current_length >= current_dialogue.length() or skip_requested:
		# Finished typing
		dialogue_label.text = current_dialogue
		is_typing = false
		await get_tree().create_timer(2.0).timeout  # Wait 2 seconds before hiding
		dialogue_box.visible = false
		return
	
	# Add next character
	dialogue_label.text = current_dialogue.substr(0, current_length + 1)
	
	# Schedule next character
	await get_tree().create_timer(typing_speed).timeout
	_start_typing()

# Input handling to skip typing
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and is_typing:
		skip_requested = true

# Add a bottle and check if all bottles are collected
func addBottle():
	bottleNum += 1
	print(bottleNum)
	if bottleNum == bottleTotal:
		print("bien ahi")
		allBottles = true

# Change scene with transition
func change_scene():
	if descanso == true:
		chooseTargetScene()
	if not animation_player.is_connected("animation_finished", _on_TransitionAnimation_finished):
		GameManager.plasticoin += bottleNum
		animation_player.animation_finished.connect(_on_TransitionAnimation_finished)  # Connect the signal only if not already connected
	animation_player.play("Scene_Transition_in")  # Start the transition animation

# Function to handle the scene change after the animation finishes
func _on_TransitionAnimation_finished(animation_name: String):
	if animation_name == "Scene_Transition_in":  # Check if the finished animation is the one we want
		chooseTargetScene()
		print(targetScene)
		get_tree().change_scene_to_file(targetScene)  # Change to the new scene
		animation_player.animation_finished.disconnect(_on_TransitionAnimation_finished)  # Disconnect the signal to avoid multiple calls

func game_over():
	targetScene = "res://Scenes/GameOverUpdate.tscn"
	change_scene()

func chooseTargetScene():
	if descanso == true:
		print(GameManager.currentLevel)
		if GameManager.levelNumber == 1:
			targetScene = "res://Scenes/Levels/edificio.tscn"
		if GameManager.levelNumber == 2:
			targetScene = ("res://Scenes/Levels/edificio2.tscn")
		if GameManager.levelNumber == 3:
			targetScene = ("res://Scenes/Levels/edificio3.tscn")
		if GameManager.levelNumber == 4:
			targetScene = ("res://Scenes/Levels/complejo.tscn")
		if GameManager.levelNumber == 5:
			targetScene = ("res://Scenes/Levels/complejo2.tscn")
		if GameManager.levelNumber == 6:
			targetScene = ("res://Scenes/Levels/bosque.tscn")
		if GameManager.levelNumber == 7:
			targetScene = ("res://Scenes/Levels/bosque2.tscn")

func stop_timer():
	timer.stop_timer()
	
func start_timer():
	timer.start_timer()
	
func reciclaje():
	print("plasticoin totales...")
	print(GameManager.plasticoin)
	if GameManager.plasticoin > 1:
		sec1.visible = true
		hide_visuals.visible = false
		if GameManager.plasticoin > 2:
			sec2.visible = true
			if GameManager.plasticoin > 3:
				sec3.visible = true
				if GameManager.plasticoin > 4:
					sec4.visible = true
					if GameManager.plasticoin > 5:
						sec5.visible = true
						if GameManager.plasticoin > 6:
							sec6.visible = true
					
func toggle_timer():
	if timer.visible == false:
		timer.visible = true
	else:
		timer.visible = false
