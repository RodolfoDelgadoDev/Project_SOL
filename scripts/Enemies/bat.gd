extends Node2D

# Define the size of the grid
@export var GRID_SIZE = 64
@export var move_duration = 0.1  # Duration in seconds to complete the move
@export var initial_wait_time = 0.5  # Initial wait time before starting patrol
@export var wait_time = 0.5  # Time to wait at each patrol point
@export var damage: int
@export var health: int = 20

# Change AudioEffect to AudioStream for playback
@export var attackSFX: AudioStream
@export var moveSFX: AudioStream
@export var hurtSFX: AudioStream

# Define the patrol path as a list of directions
@export var patrol_path: Array[Vector2] = []

@onready var animator: AnimationPlayer = $CharacterBody2D/AnimationPlayer
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var animated_sprite: AnimatedSprite2D = $CharacterBody2D/AnimatedSprite2D

var character_body: CharacterBody2D
var current_patrol_index = 0
var target_velocity: Vector2 = Vector2.ZERO
var moving: bool = false
var move_timer: float = 0.0
var wait_timer: float = 0.0
var initial_position: Vector2
var initialized: bool = false  # Flag to indicate initialization

func _ready():
	# Reference the CharacterBody2D node
	character_body = $CharacterBody2D
	wait_timer = -initial_wait_time  # Start with an initial wait time
	initialized = true

func _process(delta):
	if not initialized:
		return
	if alive():
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
				wait_timer = 0.0

				# Check if the position has changed
				if character_body.position != initial_position:
					# Move was successful, advance the patrol index
					current_patrol_index = (current_patrol_index + 1) % patrol_path.size()
		else:
			# Wait at the current position
			wait_timer += delta
			if wait_timer >= wait_time:
				start_moving()

# Start moving in the current patrol direction
func start_moving():
	if alive():
		if patrol_path.size() > 0:
			# Record the initial position before attempting to move
			initial_position = character_body.position
			target_velocity = patrol_path[current_patrol_index] * (GRID_SIZE / move_duration)
			moving = true
			update_flip()
			move_timer = 0.0
			


		# Play move sound effect
		#audio_player.stream = moveSFX
		#audio_player.play()

# Funcion para ver si el amiguito esta vivo
func alive() -> bool:
	return health > 0
	
# Ensure the enemy is always aligned with the grid
func _physics_process(_delta):
	if alive():
		if not moving:
			character_body.position = character_body.position.snapped(Vector2(GRID_SIZE, GRID_SIZE))
			print(target_velocity.x)
		#update_flip()


func update_flip():
	if patrol_path[current_patrol_index].x == 1:
		animated_sprite.flip_h = true
	if patrol_path[current_patrol_index].x == -1:
		animated_sprite.flip_h = false

func _on_area_2d_area_shape_entered(_area_rid: RID, area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	if alive():
		if area.is_in_group("player"):
			audio_player.stream = attackSFX
			audio_player.play()  # Play attack sound
			GameManager.takeDamage(damage)
			print(GameManager.Segundos)
		if area.is_in_group("weapon"):
			audio_player.stream = hurtSFX
			audio_player.play()
			takeDamage()
	
func takeDamage():
	if health <= 0:
		return
	else:
		health -= GameManager.playerDamage
		animator.play("takeDamage")
		if health <= 0:
			await audio_player.finished
			queue_free()
