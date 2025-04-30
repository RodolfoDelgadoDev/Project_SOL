extends Node2D

# Este nodo maneja los elementos de la escena, el timer, cuantas botellas hay, etc.
@export var segundos: int
@export var descanso: bool # if true = indica que estás en la sala de descanso
@export var targetScene: NodePath
@onready var dialogue_image: TextureRect = $CanvasLayer/DialogueBox/ColorRect
@onready var dialogue_text: Label = $CanvasLayer/DialogueBox/ColorRect/TextEdit
@onready var npc_portrait: TextureRect = $CanvasLayer/DialogueBox/ColorRect/Portrait
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
		timer.visible = false
		reciclaje()
	# Initialize cursor timer
	cursor_timer = Timer.new()
	cursor_timer.wait_time = cursor_blink_delay
	cursor_timer.one_shot = false
	cursor_timer.timeout.connect(_on_cursor_timer_timeout)
	add_child(cursor_timer)

# Start the typewriter effect
func start_typewriter(text: String, portrait: Texture):
	dialogue_image.visible = true
	npc_portrait.texture = portrait  # Ensure this is a valid Texture
	typewriter_text = text
	typewriter_index = 0
	dialogue_text.text = ""  # Clear the text initially
	is_typewriter_active = true
	# Start the timer for the typewriter effect
	$CanvasLayer/DialogueBox/textTimer.wait_time = typewriter_delay
	$CanvasLayer/DialogueBox/textTimer.start()

# Stop the typewriter effect
func stop_typewriter():
	$CanvasLayer/DialogueBox/textTimer.stop()
	# Start a 2-second delay before hiding the dialogue box
	$CanvasLayer/DialogueBox/hideTimer.wait_time = 2.0  # 2 seconds
	$CanvasLayer/DialogueBox/hideTimer.start()

# Handle the timer timeout event for the typewriter effect
func _on_text_timer_timeout() -> void:
	if is_typewriter_active and typewriter_index < typewriter_text.length():
		dialogue_text.text += typewriter_text[typewriter_index]
		typewriter_index += 1
	else:
		stop_typewriter()  # Stop the effect when the text is fully displayed
		# Start the cursor blinking
		cursor_timer.start()

# Handle the timer timeout event for hiding the dialogue box
func _on_hide_timer_timeout() -> void:
	dialogue_image.visible = false  # Hide the dialogue box
	$CanvasLayer/DialogueBox/hideTimer.stop()  # Stop the hide timer
	cursor_timer.stop()  # Stop the cursor blinking
	is_typewriter_active = false

# Handle the cursor blinking effect
func _on_cursor_timer_timeout() -> void:
	cursor_visible = !cursor_visible  # Toggle cursor visibility
	if cursor_visible:
		dialogue_text.text += "•"  # Add cursor
	else:
		dialogue_text.text = dialogue_text.text.substr(0, dialogue_text.text.length() - 1)  # Remove cursor

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
		
				
	
