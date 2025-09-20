extends Node2D

@export var move_duration = 0.1
@export var wait_time = 0.0
@export var damage: int = 1
@export var GRID_SIZE = 64
@export var fireball_length = 5
#Para la velocidad del proyectil
@export var projectile_speed: float = 20.0

@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var animated_sprite: AnimatedSprite2D = $CharacterBody2D/AnimatedSprite2D
@onready var character_body: CharacterBody2D = $CharacterBody2D

var current_patrol_index = 0
var target_velocity: Vector2 = Vector2.ZERO
var moving: bool = false
var move_timer: float = 0.0
var wait_timer: float = 0.0
var patrol_path: Array[Vector2] = []
var direction: String = "right"
var initial_position: Vector2
var previous_position: Vector2
var shoot_timer := 0.0
var hit: bool = false


func setup(fire_direction: String):
	direction = fire_direction
	create_patrol_path()
	initial_position = character_body.position
	previous_position = character_body.position
	start_moving()

func create_patrol_path():
	var dir_vector = Vector2.ZERO
	match direction:
		"up":
			dir_vector = Vector2(0, -1)
			animated_sprite.rotation_degrees = -90
		"down":
			dir_vector = Vector2(0, 1)
			animated_sprite.rotation_degrees = 90
		"left":
			dir_vector = Vector2(-1, 0)
			animated_sprite.flip_h = true
		"right":
			dir_vector = Vector2(1, 0)
			animated_sprite.flip_h = false
	
	patrol_path = []
	for i in range(fireball_length):
		patrol_path.append(dir_vector)

func _physics_process(delta):
	if not moving:
		wait_timer += delta
		if wait_timer >= wait_time:
			start_moving()
		return

	# Movimiento lineal y lento
	character_body.velocity = target_velocity
	character_body.move_and_slide()

	# Destruir si recorre la distancia máxima
	if character_body.position.distance_to(initial_position) >= GRID_SIZE * fireball_length:
		animated_sprite.play("Collision")
		await animated_sprite.animation_finished
		queue_free()

func start_moving():
	if current_patrol_index < patrol_path.size():
		initial_position = character_body.position
		# Dirección normalizada * velocidad deseada
		target_velocity = patrol_path[current_patrol_index].normalized() * projectile_speed
		moving = true

func _on_area_2d_area_shape_entered(_area_rid: RID, area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	if area.is_in_group("player") && hit == false:
		character_body.collision_mask  = 0
		character_body.collision_layer = 0
		hit = true
		GameManager.takeDamage(damage)
		explode()
	pass
	
func explode():
	animated_sprite.play("Collision")
	await animated_sprite.animation_finished
	#reproducir animacion bola de fuego
	queue_free()
