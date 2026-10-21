extends Node2D

@export var damage: int
@export var health: int = 20
@export var attackSFX: AudioStream
@export var destroySFX: AudioStream
# Legacy: ya no se usa para decidir la direccion del disparo (la direccion se
# calcula directo del vector hacia el jugador). Se deja para no romper los
# overrides que ya existen en las escenas.
@export var directions: Array[String] = ["right", "left", "down" , "up"]
@export var fireball_length = 5
@export var player_node: Node2D
@export var onlyVertical: bool = false
@export var onlyHorizontal: bool = false

@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var sprite: AnimatedSprite2D = $CharacterBody2D/AnimatedSprite2D
@onready var characterBodysp: CharacterBody2D = $CharacterBody2D

const FIREBALL_SPAWN_OFFSET := 25.0

var current_direction_index := 0
var fireball_scene = preload("res://Scenes/Entities/fireball.tscn")
var animations: Array[String] = ["Attack"]
var player_body: CharacterBody2D
var wait_time: float = RandomNumberGenerator.new().randf_range(1.5, 2.0)
var dying : bool = false

func _ready() -> void:
	if player_node:
		player_body = player_node.get_node("CharacterBody2D")
	else:
			printerr("No se pudo encontrar CharacterBody2D en el nodo del jugador")
	start_direction_cycle()

	
# Devuelve la direccion cardinal (Vector2 unitario) desde "from" hacia "to".
# Respeta onlyHorizontal / onlyVertical.
func get_direction(from: Vector2, to: Vector2) -> Vector2:
	var dir = to - from  # Vector desde "from" hacia "to"
	var sx := 1.0 if dir.x >= 0.0 else -1.0
	var sy := 1.0 if dir.y >= 0.0 else -1.0
	
	if onlyHorizontal:
		return Vector2(sx, 0)
	if onlyVertical:
		return Vector2(0, sy)
	
	# Eje dominante
	if abs(dir.x) > abs(dir.y):
		return Vector2(sx, 0)
	return Vector2(0, sy)

# Convierte un vector cardinal al string que espera fireball.setup()
func direction_to_string(dir: Vector2) -> String:
	if dir.x > 0.0:
		return "right"
	if dir.x < 0.0:
		return "left"
	if dir.y > 0.0:
		return "down"
	return "up"

func start_direction_cycle() -> void:
	while health > 0:  # Changed to > 0 since we check health >= 0 elsewhere
		var current_direction = get_direction(characterBodysp.global_position,player_body.global_position)
		await get_tree().create_timer(wait_time).timeout
		fireball(current_direction)
		await get_tree().create_timer(2).timeout
		

func fireball(direction: Vector2) -> void:
	sprite.play((animations[0]))
	var fireball_instance = fireball_scene.instantiate()
	get_parent().add_child(fireball_instance)
	fireball_instance.global_position = characterBodysp.global_position + direction * FIREBALL_SPAWN_OFFSET
	fireball_instance.setup(direction_to_string(direction))  # This initializes the movement
	audio_player.stream = attackSFX
	audio_player.play()
	

func _on_area_2d_area_shape_entered(_area_rid: RID, area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	if area.is_in_group("weapon"):
		if dying:
			return
		audio_player.stream = destroySFX
		audio_player.play()
		takeDamage()
		
	if area.is_in_group("player"):
		audio_player.stream = attackSFX
		audio_player.play()
		GameManager.takeDamage(damage)

func takeDamage():
	if dying:
		return
	health -= GameManager.playerDamage
	if health <= 0:
		dying = true
		if audio_player.playing:
			await audio_player.finished
		
		var particle_scene = load("res://Scenes/Particles/confetti.tscn")
		var particles_instance = particle_scene.instantiate()
		var particles = particles_instance.get_node("GPUParticles2D")
		particles.global_position = global_position
		get_parent().add_child(particles_instance)
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
		
		
		death_sprite.global_position = enemyposition + Vector2(5, 0) # Selecciono el spawn y le sumo un poco hacia la derecha asi no sale de adentro del bicho
		
		death_sprite.scale = Vector2(0.2, 0.2) # Cambiar el tamaño de la escala de la imagen
		
		get_parent().add_child(death_sprite)
		
		var duracion_animacion = 2.0 # 
		var distancia_subida = 30.0  

		var posicion_final = death_sprite.position + Vector2(0, -distancia_subida)

		var tween = get_tree().create_tween().set_parallel(true)

		tween.tween_property(death_sprite, "modulate:a", 0.0, duracion_animacion).set_ease(Tween.EASE_IN)


		tween.tween_property(death_sprite, "position", posicion_final, duracion_animacion).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

		tween.chain().tween_callback(death_sprite.queue_free)
