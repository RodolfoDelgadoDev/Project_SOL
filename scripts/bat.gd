extends Node2D

# Define the size of the grid
@export var GRID_SIZE = 64
@export var move_duration = 0.1  # Duration in seconds to complete the move
@export var wait_time = 0.5  # Time to wait at each patrol point
@export var damage: int

# Define the patrol path as a list of directions
@export var patrol_path: Array[Vector2] = [
	Vector2.UP, Vector2.DOWN
]

var character_body: CharacterBody2D
var current_patrol_index = 0
var target_velocity: Vector2 = Vector2.ZERO
var moving: bool = false
var move_timer: float = 0.0
var wait_timer: float = 0.0
var initial_position: Vector2

func _ready():
	# Reference the CharacterBody2D node
	character_body = $CharacterBody2D
	# Start the patrol
	start_moving()

func _process(delta):
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
				# Move failed, reset the wait timer to try again
				wait_timer = 0.0
	else:
		# Wait at the current position
		wait_timer += delta
		if wait_timer >= wait_time:
			start_moving()

# Start moving in the current patrol direction
func start_moving():
	if patrol_path.size() > 0:
		# Record the initial position before attempting to move
		initial_position = character_body.position
		target_velocity = patrol_path[current_patrol_index] * (GRID_SIZE / move_duration)
		moving = true
		move_timer = 0.0

# Ensure the enemy is always aligned with the grid
func _physics_process(_delta):
	if not moving:
		character_body.position = character_body.position.snapped(Vector2(GRID_SIZE, GRID_SIZE))


func _on_area_2d_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	print(GameManager.Segundos)
	GameManager.takeDamage(damage)
	print(GameManager.Segundos)
	
