extends Node2D

@export var damage: int
@export var health: int = 20
@export var attackSFX: AudioStream
@export var destroySFX: AudioStream
@export var wait_time: float = 1.5  # Time between direction changes
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
var player_body: CharacterBody2D
var directionsid

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

func fireball(direction: Vector2) -> void:
	sprite.play((animations[0]))
	var fireball_instance = fireball_scene.instantiate()
	get_parent().add_child(fireball_instance)
	fireball_instance.global_position = characterBodysp.global_position
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
		queue_free()
