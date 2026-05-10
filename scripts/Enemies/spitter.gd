extends Node2D

@export var damage: int
@export var health: int = 20
@export var attackSFX: AudioStream
@export var destroySFX: AudioStream
   # Time between direction changes
@export var directions: Array[String] = ["right", "left", "down" , "up"]  # Array of directions (up, down, left, right)
@export var fireball_length = 5
@export var player_node: Node2D
@export var onlyVertical: bool = false
@export var onlyHorizontal: bool = false

@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var sprite: AnimatedSprite2D = $CharacterBody2D/AnimatedSprite2D
@onready var characterBodysp: CharacterBody2D = $CharacterBody2D

var current_direction_index := 0
var fireball_scene = preload("res://Scenes/Entities/fireball.tscn")
var animations: Array[String] = ["Attack"]
var directionsDict = {"right": Vector2(25,0), "left": Vector2(-25,0), "down": Vector2(0,25), "up": Vector2(0,-25)}
var player_body: CharacterBody2D
var directionsid
var wait_time: float = RandomNumberGenerator.new().randf_range(1.5, 2.0)
var dying : bool = false

func _ready() -> void:
	if player_node:
		player_body = player_node.get_node("CharacterBody2D")
	else:
			printerr("No se pudo encontrar CharacterBody2D en el nodo del jugador")
	start_direction_cycle()

	
func get_direction(from: Vector2, to: Vector2) -> Vector2:
		
	var dir = to - from  # Vector desde "from" hacia "to"
	# Si solo quiero que solamente dispare hacia la derecha
	if onlyHorizontal:
		dir = Vector2(sign(dir.x), 0) 
		print("Horizontal") # Horizontal dominante
		if dir.x > 0:
			directionsid = 0
		else:
			directionsid = 1
		return dir
	if onlyVertical:
		if dir.y > 0:
			directionsid = 2
		else:
			directionsid = 3
		return dir
		
		
	# Si solo querés saber la dirección cardinal (izq, der, arriba, abajo)
	if abs(dir.x) > abs(dir.y):
		dir = Vector2(sign(dir.x), 0) 
		print("Horizontal") # Horizontal dominante
		if dir.x > 0:
			directionsid = 0
		else:
			directionsid = 1
		return dir
	else:
		dir = Vector2(0, sign(dir.y))
		print(("Vertical"))  # Vertical dominante
		if dir.y > 0:
			directionsid = 2
		else:
			directionsid = 3
		return dir

	

func start_direction_cycle() -> void:
	while health > 0:  # Changed to > 0 since we check health >= 0 elsewhere
		var current_direction = get_direction(characterBodysp.global_position,player_body.global_position)
		await get_tree().create_timer(wait_time).timeout
		fireball(current_direction)
		await get_tree().create_timer(2).timeout
		

func fireball(_direction: Vector2) -> void:
	sprite.play((animations[0]))
	var fireball_instance = fireball_scene.instantiate()
	get_parent().add_child(fireball_instance)
	fireball_instance.global_position = characterBodysp.global_position + directionsDict[directions[directionsid]]
	fireball_instance.setup(directions[directionsid])  # This initializes the movement
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
