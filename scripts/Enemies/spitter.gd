extends Node2D

@export var damage: int
@export var health: int = 20
@export var attackSFX: AudioStream
@export var destroySFX: AudioStream
@export var wait_time: float = 1.0  # Time between direction changes
@export var directions: Array[String] = ["right"]  # Array of directions (up, down, left, right)
@export var fireball_length = 5

@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var sprite: AnimatedSprite2D = $CharacterBody2D/AnimatedSprite2D

var current_direction_index := 0
var fireball_scene = preload("res://Scenes/Entities/fireball.tscn")
var animations: Array[String] = ["Attack"]

var dying : bool = false

func _ready() -> void:
	start_direction_cycle()

func start_direction_cycle() -> void:
	while health > 0:  # Changed to > 0 since we check health >= 0 elsewhere
		var current_direction = directions[current_direction_index]
		await get_tree().create_timer(wait_time).timeout
		if health > 0:  # Only fire if still alive
			fireball(current_direction)
			current_direction_index = (current_direction_index + 1) % directions.size()

func fireball(direction: String) -> void:
	sprite.play((animations[0]))
	var fireball_instance = fireball_scene.instantiate()
	get_parent().add_child(fireball_instance)
	fireball_instance.global_position = global_position
	fireball_instance.setup(direction)  # This initializes the movement
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
		queue_free()
