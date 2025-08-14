extends Node2D

@export var move_duration = 0.1
@export var wait_time = 0.0
@export var damage: int = 1
@export var GRID_SIZE = 64
@export var fireball_length = 5

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

func _process(delta):
	if moving:
		var remaining_time = move_duration - move_timer
		character_body.velocity = target_velocity * min(delta, remaining_time) / move_duration
		character_body.move_and_slide()
		move_timer += delta
		
		if move_timer >= move_duration:
			# Check if position changed after movement attempt
			if character_body.position.distance_to(previous_position) < 1.0:  # Basically didn't move
				print("Fireball stuck - destroying")
				queue_free()
				return
				
			previous_position = character_body.position
			character_body.position = character_body.position.snapped(Vector2(GRID_SIZE, GRID_SIZE))
			moving = false
			move_timer = 0.0
			wait_timer = 0.0
			
			current_patrol_index += 1
			if current_patrol_index >= patrol_path.size():
				queue_free()
	else:
		wait_timer += delta
		if wait_timer >= wait_time:
			start_moving()

func start_moving():
	if current_patrol_index < patrol_path.size():
		initial_position = character_body.position
		target_velocity = patrol_path[current_patrol_index] * (GRID_SIZE / move_duration)
		moving = true
		move_timer = 0.0

func _on_area_2d_area_shape_entered(_area_rid: RID, area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	if area.is_in_group("player"):
		GameManager.takeDamage(damage)
		explode()
	pass
	
func explode():
	#reproducir animacion bola de fuego
	queue_free()
