extends CharacterBody2D

# Define the size of the grid
@export var GRID_SIZE = 64
@export var move_duration = 0.1  # Duration in seconds to complete the move

# Store the velocity needed to move one grid cell
var target_velocity: Vector2 = Vector2.ZERO
var moving: bool = false
var move_timer: float = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not moving:
		# Check for input and set the direction
		if Input.is_action_just_pressed("ui_up"):
			target_velocity = Vector2.UP * (GRID_SIZE / move_duration)
			moving = true
		elif Input.is_action_just_pressed("ui_down"):
			target_velocity = Vector2.DOWN * (GRID_SIZE / move_duration)
			moving = true
		elif Input.is_action_just_pressed("ui_left"):
			target_velocity = Vector2.LEFT * (GRID_SIZE / move_duration)
			moving = true
		elif Input.is_action_just_pressed("ui_right"):
			target_velocity = Vector2.RIGHT * (GRID_SIZE / move_duration)
			moving = true

	if moving:
		# Calculate the movement step
		var remaining_time = move_duration - move_timer
		velocity = target_velocity * min(delta, remaining_time) / move_duration
		move_and_slide()
		move_timer += delta

		# Stop moving if the duration is reached
		if move_timer >= move_duration:
			# Snap to the nearest grid position to ensure precision
			position = position.snapped(Vector2(GRID_SIZE, GRID_SIZE))
			moving = false
			move_timer = 0.0
			target_velocity = Vector2.ZERO

# Ensure the player is always aligned with the grid
func _physics_process(delta):
	if not moving:
		position = position.snapped(Vector2(GRID_SIZE, GRID_SIZE))
