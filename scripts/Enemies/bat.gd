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
var SceneManager

func _ready():
	# Reference the CharacterBody2D node
	character_body = $CharacterBody2D
	wait_timer = -initial_wait_time  # Start with an initial wait time
	initialized = true
	SceneManager = get_parent()

func _physics_process(delta):
	if not initialized:
		return
	if alive() && !GameManager.goal:
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
			audio_player.stream = moveSFX
			audio_player.play()

			


		# Play move sound effect
		#audio_player.stream = moveSFX
		#audio_player.play()

# Funcion para ver si el amiguito esta vivo
func alive() -> bool:
	return health > 0
	

func update_flip():
	if patrol_path[current_patrol_index].x == 1:
		animated_sprite.flip_h = true
	if patrol_path[current_patrol_index].x == -1:
		animated_sprite.flip_h = false

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
	
func takeDamage():
	if health <= 0:
		return
	else:
		health -= GameManager.playerDamage
		animator.play("takeDamage")
		if health <= 0:
			var particle_scene = load("res://Scenes/Particles/confetti.tscn")
			var particles_instance = particle_scene.instantiate()
			var particles = particles_instance.get_node("GPUParticles2D")
			get_parent().add_child(particles_instance)
			# Se asigna DESPUES de add_child: antes de estar en el arbol Godot lo toma como posicion local
			particles.global_position = character_body.global_position
			particles.emitting = true
			particles.restart()
			spawn_random_death_sprite()
			queue_free()

func spawn_random_death_sprite():
	var folder_path = "res://art/UI/Onomatopeyas/"
	var enemy = $CharacterBody2D
	var enemyposition = enemy.global_position
	var files = []
	var dir = DirAccess.open(folder_path)
	# Si existe direccion
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			# Loop para tomar pngs al array
			if !dir.current_is_dir() and file_name.ends_with(".png"):
				files.append(file_name)
			file_name = dir.get_next()
		dir.list_dir_end()

	if files.size() > 0:
		# 1. Elegir uno al azar
		var random_index = randi() % files.size()
		var chosen_file = files[random_index]
		
		# 2. Crear un nuevo Sprite2D
		var death_sprite = Sprite2D.new()
		death_sprite.texture = load(folder_path + chosen_file)
		
		
		# (la posicion global se asigna despues del add_child, ver mas abajo)
		
		death_sprite.scale = Vector2(0.2, 0.2) # Cambiar el tamaño de la escala de la imagen
		
		get_parent().add_child(death_sprite)
		# Se asigna DESPUES de add_child: antes de estar en el arbol Godot lo toma como posicion local.
		# Selecciono el spawn y le sumo un poco hacia la derecha asi no sale de adentro del bicho
		death_sprite.global_position = enemyposition + Vector2(5, 0)
		
		var duracion_animacion = 2.0 # 
		var distancia_subida = 30.0  

		var posicion_final = death_sprite.position + Vector2(0, -distancia_subida)

		var tween = get_tree().create_tween().set_parallel(true)

		tween.tween_property(death_sprite, "modulate:a", 0.0, duracion_animacion).set_ease(Tween.EASE_IN)


		tween.tween_property(death_sprite, "position", posicion_final, duracion_animacion).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

		tween.chain().tween_callback(death_sprite.queue_free)
