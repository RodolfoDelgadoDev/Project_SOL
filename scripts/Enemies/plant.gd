extends Node2D

@export var quieto : bool = true  # Enemies start stationary
@export var GRID_SIZE = 64
@export var move_duration = 0.1  # Seconds to complete the move
@export var wait_time = 0.5      # Seconds to wait before trying the next move
@export var damage: int
@export var health: int
@export var attackSFX: AudioStream
@export var moveSFX: AudioStream
@export var hurtSFX: AudioStream
@export var detection_range: int = 5  # Default detection range in grid spaces

var character_body: CharacterBody2D
var target_velocity: Vector2 = Vector2.ZERO
var moving: bool = false
var move_timer: float = 0.0
var wait_timer: float = 0.0
var initial_position: Vector2

# Store the last difference vector from enemy to player and a flag to check if alternative move was tried.
var last_diff: Vector2 = Vector2.ZERO
var tried_alternative: bool = false

@export var player_node_path: NodePath
@onready var player_body: CharacterBody2D = get_node(player_node_path).get_node("CharacterBody2D")
@onready var animator : AnimationPlayer = $CharacterBody2D/AnimationPlayer
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var animatedSprite: AnimatedSprite2D = $CharacterBody2D/AnimatedSprite2D


func _ready():
	# Reference our own CharacterBody2D node.
	character_body = $CharacterBody2D
	# Start in a stationary state.
	quieto = true


func _physics_process(delta: float):
	if alive() && GameManager.goal == false:
		# Check player distance and update `quieto` if necessary.
		player_distance()

		if not quieto:
			if moving:
				var remaining_time = move_duration - move_timer
				# Move smoothly toward the target velocity.
				character_body.velocity = target_velocity * min(delta, remaining_time) / move_duration
				character_body.move_and_slide()
				move_timer += delta

				if move_timer >= move_duration:
					# Snap the enemy to the grid.
					character_body.position = character_body.position.snapped(Vector2(GRID_SIZE, GRID_SIZE))
					moving = false
					move_timer = 0.0

					# If no movement occurred and we haven't tried the alternative axis yet...
					if character_body.position == initial_position and not tried_alternative:
						tried_alternative = true
						try_alternative_move()
					else:
						wait_timer = 0.0
			else:
				# Wait until it's time to move again.
				wait_timer += delta
				if wait_timer >= wait_time:
					start_moving()


# Check if the player is within the detection range.
func player_distance():
	if not player_body:
		print("Player not found!")
		return

	var player_position = player_body.global_position
	var enemy_position = character_body.global_position
	var distance = (player_position - enemy_position).length()  # Distance in pixels

	# Convert detection range from grid spaces to pixels.
	var detection_range_pixels = detection_range * GRID_SIZE

	# If the player is within range, set `quieto` to false.
	if distance <= detection_range_pixels:
		quieto = false


# Calculate the primary move direction (the axis with the larger distance to the player).
func start_moving():
	if not player_body:
		print("Player not found!")
		return

	var player_position = player_body.global_position
	var enemy_position = character_body.global_position
	last_diff = player_position - enemy_position
	
	# If the enemy is already at the player's position, do nothing.
	if last_diff == Vector2.ZERO:
		return
	
	tried_alternative = false
	
	# Choose the primary axis.
	if abs(last_diff.x) > abs(last_diff.y):
		# Move horizontally.
		if last_diff.x > 0:
			target_velocity = Vector2.RIGHT * (GRID_SIZE / move_duration)
			updateFlip(true)
		else:
			target_velocity = Vector2.LEFT * (GRID_SIZE / move_duration)
			updateFlip(false)
	else:
		# Move vertically.
		if last_diff.y > 0:
			target_velocity = Vector2.DOWN * (GRID_SIZE / move_duration)
		else:
			target_velocity = Vector2.UP * (GRID_SIZE / move_duration)
	
	initial_position = character_body.position
	moving = true
	move_timer = 0.0
	move_timer = 0.0
	audio_player.stream = moveSFX
	audio_player.play()


# Try moving along the other axis.
func try_alternative_move():
	# If primary axis was horizontal, alternative is vertical, and vice versa.
	if abs(last_diff.x) > abs(last_diff.y):
		# Primary was horizontal; try vertical.
		if last_diff.y > 0:
			target_velocity = Vector2.DOWN * (GRID_SIZE / move_duration)
		else:
			target_velocity = Vector2.UP * (GRID_SIZE / move_duration)
	else:
		# Primary was vertical; try horizontal.
		if last_diff.x > 0:
			target_velocity = Vector2.RIGHT * (GRID_SIZE / move_duration)
			updateFlip(true)
		else:
			target_velocity = Vector2.LEFT * (GRID_SIZE / move_duration)
			updateFlip(false)
	
	# Attempt the alternative move immediately.
	initial_position = character_body.position
	moving = true
	move_timer = 0.0
	


func _on_area_2d_area_shape_entered(_area_rid: RID, area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	if alive() && GameManager.Segundos > 0:
		if area.is_in_group("player"):
			audio_player.stream = attackSFX
			audio_player.play()  # Play attack sound
			GameManager.takeDamage(damage)
			print(GameManager.Segundos)
		if area.is_in_group("weapon"):
			audio_player.stream = hurtSFX
			audio_player.play()
			takeDamage()
			print (health)


func alive() -> bool:
	return health > 0


func takeDamage():
	if health <= 0:
		if audio_player.playing:
			await audio_player.finished
		queue_free()
	else:
		health -= GameManager.playerDamage
		animator.play("takeDamage")
		if health <= 0:
			if audio_player.playing:
				await audio_player.finished
			var particle_scene = load("res://Scenes/Particles/confetti.tscn")
			var particles_instance = particle_scene.instantiate()
			var particles = particles_instance.get_node("GPUParticles2D")
			particles.global_position = character_body.global_position
			get_parent().add_child(particles_instance)
			particles.emitting = true
			particles.restart()
			takeDamage()


func updateFlip(dir: bool):
	if dir == false:
		animatedSprite.flip_h = false
	else:
		animatedSprite.flip_h = true
