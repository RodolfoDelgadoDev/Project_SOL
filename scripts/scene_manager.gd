extends Node2D

# Este nodo maneja los elementos de la escena, el timer, cuantas botellas hay, etc.
@export var segundos : int
@export var descanso : bool #if true = indica que estás en la sala de descanso
@onready var dialogue_image : TextureRect = $CanvasLayer/DialogueBox/ColorRect
@onready var dialogue_text : Label = $CanvasLayer/DialogueBox/ColorRect/TextEdit
@onready var npc_portrait : TextureRect = $CanvasLayer/DialogueBox/ColorRect/Portrait

var bottleNum : int = 0
var bottleTotal : int
var allBottles : bool = false

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
	GameManager.Segundos = segundos
	if descanso == true:
		pass
	else:
		GameManager.Segundos = segundos
		for child in get_children():
			if child.is_in_group("pickup"):
				bottleTotal += 1
		print("Total bottles found: ", bottleTotal)
	
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
		
func change_scene(scene):
	get_tree().change_scene_to_file(scene)
