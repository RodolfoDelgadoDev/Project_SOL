extends Node2D

var directions = {
	"UP": [Vector2.UP, "AttackUp", "WalkUp"],
	"DOWN": [Vector2.DOWN, "AttackDown", "WalkDown"],
	"LEFT": [Vector2.LEFT, "AttackLeft", "WalkLeft"],
	"RIGHT": [Vector2.RIGHT, "AttackRight", "WalkRight"]
	}
@onready var attack_sprite: Sprite2D = $CharacterBody2D/Area2D/AttackSprite
@onready var animaton: AnimatedSprite2D = $CharacterBody2D/AnimatedSprite2D
@onready var lastDir = "DOWN"
@onready var attack_timer: Timer = $attack_timer
@onready var attack_area: CollisionShape2D = $CharacterBody2D/Area2D/AttackSprite/Attack_area/CollisionShape2D

# Define the size of the grid
@export var GRID_SIZE = 64
@export var move_duration = 0.1  # Duration in seconds to complete the move

# Reference to the CharacterBody2D node
var character_body: CharacterBody2D
var target_velocity: Vector2 = Vector2.ZERO
var moving: bool = false
var move_timer: float = 0.0
var can_attack: bool = true

func _ready():
	# Reference the CharacterBody2D node
	character_body = $CharacterBody2D
	attack_sprite.visible = false
	attack_area.disabled = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("attack"):
		basicAttack(lastDir)
	if not moving:
		# Check for input and set the direction
		if Input.is_action_just_pressed("ui_up"):
			target_velocity = Vector2.UP * (GRID_SIZE / move_duration)
			moving = true
			lastDir = "UP"
			walkAnimation(lastDir)
		elif Input.is_action_just_pressed("ui_down"):
			target_velocity = Vector2.DOWN * (GRID_SIZE / move_duration)
			moving = true
			lastDir = "DOWN"
			walkAnimation(lastDir)
		elif Input.is_action_just_pressed("ui_left"):
			target_velocity = Vector2.LEFT * (GRID_SIZE / move_duration)
			moving = true
			lastDir = "LEFT"
			walkAnimation(lastDir)
		elif Input.is_action_just_pressed("ui_right"):
			target_velocity = Vector2.RIGHT * (GRID_SIZE / move_duration)
			moving = true
			lastDir = "RIGHT"
			walkAnimation(lastDir)
			

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
			target_velocity = Vector2.ZERO

# Ensure the player is always aligned with the grid
func _physics_process(_delta):
	if not moving:
		character_body.position = character_body.position.snapped(Vector2(GRID_SIZE, GRID_SIZE))

func basicAttack(dir):
	if can_attack == true:
		can_attack = false
		attack_area.disabled = false
		# Set the position of the attack sprite
		var direction_vector = directions[dir][0]
		attack_sprite.position = direction_vector * GRID_SIZE  # Ajusta la posición según la dirección
		# Show the attack sprite
		animaton.play(directions[dir][1])
		attack_sprite.visible = true
		# Optional: Add a timer to hide the attack sprite after a short delay
		attack_timer.start() #empieza el timer para que no puedas atacar infinito
	

# Function to hide the attack sprite
func _hide_attack_sprite():
	attack_sprite.visible = false
	animaton.play("Idle")


func _on_attack_timer_timeout() -> void:
	can_attack = true
	attack_area.disabled = true
	_hide_attack_sprite()

func walkAnimation(dir):
	animaton.play(directions[dir][2])

func _on_animated_sprite_2d_animation_finished() -> void:
	animaton.play("Idle")
