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
@export var escape_range: int = 5  # Grid cells to start escaping
@export var calm_range: int = 8    # Grid cells to return to idle
@export var ninja_boss: bool = false

var character_body: CharacterBody2D
var target_velocity: Vector2 = Vector2.ZERO
var moving: bool = false
var move_timer: float = 0.0
var wait_timer: float = 0.0
var initial_position: Vector2

# Store the last difference vector from enemy to player and a flag to check if alternative move was tried.
var last_diff: Vector2 = Vector2.ZERO
var tried_alternative: bool = false
@export var light_node: Node2D

@export var player_node_path: NodePath
@onready var player_body: CharacterBody2D = get_node(player_node_path).get_node("CharacterBody2D")
@onready var animator : AnimationPlayer = $CharacterBody2D/AnimationPlayer
@onready var animaton: AnimatedSprite2D = $CharacterBody2D/AnimatedSprite2D
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var animatedSprite: AnimatedSprite2D = $CharacterBody2D/AnimatedSprite2D
@onready var light_timer : Timer = $light_timer

var thief_light = load("res://Scenes/Entities/thief_color_lights.tscn")

func _ready():
	# Reference our own CharacterBody2D node.
	character_body = $CharacterBody2D
	# Start in a stationary state.
	quieto = true
	get_parent().bottleTotal+=1


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
	else:	
		animaton.play("Puff")

# Check if the player is within the detection range.
func player_distance():
	if not player_body:
		print("Player not found!")
		quieto = true
		return
	
	var player_position = player_body.global_position
	var enemy_position = character_body.global_position
	var distance = (player_position - enemy_position).length() / GRID_SIZE
	
	# Three states:
	# - Close: player is within escape range (flee)
	# - Mid: player is between escape and calm range (continue current behavior)
	# - Far: player beyond calm range (return to idle)
	
	if distance <= escape_range:
		quieto = false  # Flee!
	elif distance >= calm_range:
		quieto = true   # Calm down
	# Else maintain current state
	
	# Optional: print for debugging
	#print("Player distance: ", distance, " quieto: ", quieto)


# Calculate the primary move direction (the axis with the larger distance to the player).
# Modified to flee instead of chase
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
		# Move horizontally (away from player).
		if last_diff.x > 0:
			# Player is to the right, so move left
			target_velocity = Vector2.LEFT * (GRID_SIZE / move_duration)
			updateFlip(false)
		else:
			# Player is to the left, so move right
			target_velocity = Vector2.RIGHT * (GRID_SIZE / move_duration)
			updateFlip(true)
	else:
		# Move vertically (away from player).
		if last_diff.y > 0:
			# Player is below, so move up
			target_velocity = Vector2.UP * (GRID_SIZE / move_duration)
		else:
			# Player is above, so move down
			target_velocity = Vector2.DOWN * (GRID_SIZE / move_duration)
	
	initial_position = character_body.position
	moving = true
	move_timer = 0.0
	move_timer = 0.0
	audio_player.stream = moveSFX
	audio_player.play()


# Try moving along the other axis (modified for fleeing).
func try_alternative_move():
	# List all possible escape directions (prioritized)
	var escape_directions = []
	var player_dir = (player_body.global_position - character_body.global_position).normalized()
	
	# Prioritize directions away from player
	if abs(player_dir.x) > abs(player_dir.y):
		# Horizontal priority
		escape_directions.append(Vector2.LEFT if player_dir.x > 0 else Vector2.RIGHT)
		escape_directions.append(Vector2.UP)
		escape_directions.append(Vector2.DOWN)
	else:
		# Vertical priority
		escape_directions.append(Vector2.UP if player_dir.y > 0 else Vector2.DOWN)
		escape_directions.append(Vector2.LEFT)
		escape_directions.append(Vector2.RIGHT)
	
	# Add opposite of primary direction as last resort
	escape_directions.append(-escape_directions[0])
	
	# Try each direction until one works
	for dir in escape_directions:
		# Test if this direction is free (simple raycast)
		var space_state = get_world_2d().direct_space_state
		var query = PhysicsRayQueryParameters2D.create(
			character_body.global_position,
			character_body.global_position + dir * GRID_SIZE,
			#collision_mask
		)
		var result = space_state.intersect_ray(query)
		
		if result.is_empty():
			# This direction is clear, move there
			target_velocity = dir * (GRID_SIZE / move_duration)
			updateFlip(dir.x > 0)
			
			initial_position = character_body.position
			moving = true
			move_timer = 0.0
			return
	
	# If all directions blocked, pick random and force move
	target_velocity = escape_directions[randi() % escape_directions.size()] * (GRID_SIZE / move_duration)
	updateFlip(target_velocity.x > 0)
	initial_position = character_body.position
	moving = true
	move_timer = 0.0


func _on_area_2d_area_shape_entered(_area_rid: RID, area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	if alive() && GameManager.Segundos > 0:
		if area.is_in_group("weapon"):
			takeDamage()


func alive() -> bool:
	return health > 0


func takeDamage():
	if health <= 0:
		light_timer.stop()
		die()
	else:
		audio_player.stream = hurtSFX
		audio_player.play()
		health -= GameManager.playerDamage
		animator.play("takeDamage")
		if health <= 0:
			light_timer.stop()
			GameManager.Segundos += 5
			get_parent().addBottle()
			if audio_player.playing:
				await audio_player.finished
			die()

func die():
	delete_lights()
	GameManager.Segundos += 5
	get_parent().addBottle()
	if ninja_boss:
		GameManager.ninja_boss +=1
	var particle_scene = load("res://Scenes/Particles/confetti.tscn")
	var particles_instance = particle_scene.instantiate()
	var particles = particles_instance.get_node("GPUParticles2D")
	particles.global_position = character_body.global_position
	get_parent().add_child(particles_instance)
	particles.emitting = true
	particles.restart()
	if audio_player.playing:
				await audio_player.finished
	if animaton.is_playing():
		await animaton.animation_finished
		queue_free()
	

func _on_animated_sprite_2d_animation_finished() -> void:
	print("holaa")

func updateFlip(dir: bool):
	if dir == false:
		animatedSprite.flip_h = false
	else:
		animatedSprite.flip_h = true
		
@export var max_lights: int = 6  # Maximum number of allowed lights

func spawn_light():
	if not thief_light:
		push_error("Light scene not loaded!")
		return
		
	var light = thief_light.instantiate()
	if not light:
		push_error("Failed to instantiate light")
		return
	
	# Count existing lights and remove oldest if needed
	var current_lights = get_lights()
	if current_lights.size() >= max_lights:
		var oldest_light = current_lights[0]
		oldest_light.queue_free()
	
	# Add new light
	add_child(light)
	light.position = character_body.position
	#print("Spawned light (Total: ", current_lights.size() + 1, ")")

func get_lights():
	var lights = []
	for child in get_children():
		if child.is_in_group("enemy_light"):  # Add this group to your light scene
			lights.append(child)
	# Sort by age (process order)
	lights.sort_custom(func(a, b): return a.get_index() < b.get_index())
	return lights
	
func delete_lights():
	for child in get_children():
		if child.is_in_group("enemy_light"):  # Add this group to your light scene
			child.queue_free()
			print ("deleted light")

func _on_light_timer_timeout() -> void:
	spawn_light()
