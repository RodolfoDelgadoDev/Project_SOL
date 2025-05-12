extends Node2D

var directions = {
	"UP": [Vector2.UP, "AttackUp", "WalkUp", "HiUp"],
	"DOWN": [Vector2.DOWN, "AttackDown", "WalkDown", "HiDown"],
	"LEFT": [Vector2.LEFT, "AttackLeft", "WalkLeft", "HiLeft"],
	"RIGHT": [Vector2.RIGHT, "AttackRight", "WalkRight", "HiRight"]
}

@onready var attack_sprite: Sprite2D = $CharacterBody2D/Area2D/AttackSprite
@onready var animaton: AnimatedSprite2D = $CharacterBody2D/AnimatedSprite2D
@onready var lastDir = "DOWN"
@onready var attack_timer: Timer = $attack_timer
@onready var attack_area: CollisionShape2D = $CharacterBody2D/Area2D/AttackSprite/Attack_area/CollisionShape2D
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var camera: Camera2D = $CharacterBody2D/Camera2D

# Define the size of the grid
@export var GRID_SIZE = 64
@export var move_duration = 0.1  # Duration in seconds to complete the move
@export var attackSFX: AudioStream
@export var hurtSFX: AudioStream

# Array for movement sound effects
@export var movementSFX: Array[AudioStream] = []

# Pitch variation settings
@export var minPitch: float = -0.3  # Minimum pitch variation
@export var maxPitch: float = 0.2   # Maximum pitch variation

# Reference to the CharacterBody2D node
var character_body: CharacterBody2D
var target_velocity: Vector2 = Vector2.ZERO
var moving: bool = false
var move_timer: float = 0.0
var can_attack: bool = true
# Variable que chequea si esta en un lugar para atacar o un lugar para saludar
@onready var current_status: int = 1

# Camera shake variables
@export var shake_intensity: float = 0.0
@export var shake_duration: float = 0.0
@export var shake_decay: float = 5.0

func _ready():
	# Reference the CharacterBody2D node
	character_body = $CharacterBody2D
	attack_sprite.visible = false
	attack_area.disabled = true
	# Condicional donde se setea el valor de la animacion
	# El valor 1 es que puede saludar
	# El valor 0 es que ataca 
	if get_parent().descanso != true:
		current_status = 0

func _physics_process(delta: float):
	if alive():
		if Input.is_action_just_pressed("attack"):
			basicAttack(lastDir)
		if not moving:
			# Check for input and set the direction
			if Input.is_action_just_pressed("ui_up"):
				move(Vector2.UP)
			elif Input.is_action_just_pressed("ui_down"):
				move(Vector2.DOWN)
			elif Input.is_action_just_pressed("ui_left"):
				move(Vector2.LEFT)
			elif Input.is_action_just_pressed("ui_right"):
				move(Vector2.RIGHT)
		if moving:
			# Calculate the movement step
			var remaining_time = move_duration - move_timer
			character_body.velocity = target_velocity * min(delta, remaining_time) / move_duration
			character_body.move_and_slide()
			move_timer += delta

			# Stop moving if the duration is reached
			if move_timer >= move_duration:
				# Snap to the nearest grid position to ensure precision
				character_body.position = character_body.position.snapped(Vector2(GRID_SIZE, GRID_SIZE))
				moving = false
				move_timer = 0.0
				target_velocity = Vector2.ZERO
	else:	
		animaton.play("Death")

	# Handle camera shake
	if shake_duration > 0:
		# Apply random offset to the camera
		camera.offset = Vector2(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity)
		)
		# Reduce shake intensity over time
		shake_duration -= delta
		shake_intensity = lerp(shake_intensity, 0.0, shake_decay * delta)
	else:
		# Reset the camera offset when shaking is done
		camera.offset = Vector2.ZERO

# Function to handle movement
func move(direction: Vector2):
	target_velocity = direction * (GRID_SIZE / move_duration)
	moving = true
	lastDir = direction_to_string(direction)
	walkAnimation(lastDir)
	play_random_movement_sound()

# Function to play a random movement sound with pitch variation
func play_random_movement_sound():
	if movementSFX.size() > 0:
		var random_index = randi() % movementSFX.size()  # Get a random index
		audio_player.stream = movementSFX[random_index]  # Select a random sound
		# Set a random pitch within the defined range
		var pitch_variation = randf_range(minPitch, maxPitch)
		audio_player.pitch_scale = 1.0 + pitch_variation  # Adjust pitch scale
		audio_player.play()  # Play the selected sound

func basicAttack(dir):
	if get_parent().descanso != true:
		current_status = 0
	if can_attack == true:
		can_attack = false
		attack_area.disabled = false
		# Set the position of the attack sprite
		var direction_vector = directions[dir][0]
		attack_sprite.position = direction_vector * GRID_SIZE  # Adjust position based on direction
		# Show the attack sprite
		audio_player.stream = attackSFX
		# Condicional para atacar
		if current_status == 0:
			animaton.play(directions[dir][1])
		# Si no deberia saludar como una tipaza que es
		else:
			animaton.play(directions[dir][3])
		audio_player.play()  # Play attack sound
			
		attack_sprite.visible = true
		# Optional: Add a timer to hide the attack sprite after a short delay
		attack_timer.start()  # Start the timer to prevent infinite attacking

# Function to hide the attack sprite
func _hide_attack_sprite():
	attack_sprite.visible = false
	animaton.play("Idle")

# Function to check if the player is still alive
func alive() -> bool:
	return GameManager.Segundos > 0

func _on_attack_timer_timeout() -> void:
	if alive():
		can_attack = true
		attack_area.disabled = true
		_hide_attack_sprite()

func walkAnimation(dir):
	animaton.play(directions[dir][2])

func _on_animated_sprite_2d_animation_finished() -> void:
	if alive():
		animaton.play("Idle")

# Helper function to convert direction vector to string
func direction_to_string(direction: Vector2) -> String:
	if direction == Vector2.UP:
		return "UP"
	elif direction == Vector2.DOWN:
		return "DOWN"
	elif direction == Vector2.LEFT:
		return "LEFT"
	elif direction == Vector2.RIGHT:
		return "RIGHT"
	return ""

func _on_area_2d_area_shape_entered(_area_rid: RID, area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	if area.is_in_group("enemy"):
		# Start the camera shake
		shake_intensity = 5.0  # Adjust intensity as needed
		shake_duration = 0.3    # Adjust duration as needed
