extends CharacterBody2D

@export var move_speed: float = 100.0
@export var chase_duration: float = 2.0 # Duration for 'chasing' phase
@export var attack_windup_duration: float = 1.5 # Duration for 'winding_up' phase
# @export var blink_interval_windup: float = 0.1 # Fast blink interval for winding up (Removed visual aids)
# @export var blink_interval_vulnerable: float = 0.5 # Slow blink interval for vulnerable (Removed visual aids)
@export var attack_duration: float = 0.5 # Duration for 'attacking' phase (0.5 seconds as requested)
@export var vulnerable_duration: float = 3.0 # Duration for 'vulnerable' phase (3 seconds as requested)
@export var attack_damage: float = 10.0
@export var player_node: Node2D
@export var health: int

# For the shield
@export var shield: MeshInstance2D

@onready var attack_area: Area2D = $Area2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D # Ensure your AnimatedSprite2D node is named this

var player_body: CharacterBody2D = null
var state: String = "chasing" # Possible states: "chasing", "winding_up", "attacking", "vulnerable"
var movement_timer: Timer = null
var windup_timer: Timer = null
# var blink_timer: Timer = null # Removed as visual aids are removed
var attack_timer: Timer = null
var vulnerable_timer: Timer = null
var brokenGen: int = 0
# var original_modulate: Color # To store the original modulate color of the sprite (Removed as visual aids are removed)


func _ready():
	# Initialize all timers
	movement_timer = _create_timer(true)
	windup_timer = _create_timer(true)
	# blink_timer = _create_timer(false) # Blink timer is not one-shot as it repeats (Removed visual aids)
	attack_timer = _create_timer(true)
	vulnerable_timer = _create_timer(true)

	# Connect timer timeouts to their respective functions
	movement_timer.timeout.connect(_on_movement_timeout)
	windup_timer.timeout.connect(_on_windup_timeout)
	# blink_timer.timeout.connect(_on_blink_timeout) # Removed as visual aids are removed
	attack_timer.timeout.connect(_on_attack_timeout)
	vulnerable_timer.timeout.connect(_on_vulnerable_timeout)

	# Connect area signals for attack detection
	attack_area.area_entered.connect(_on_attack_area_entered)
	attack_area.body_entered.connect(_on_attack_body_entered)

	# Find player's CharacterBody2D
	if player_node:
		player_body = player_node.get_node("CharacterBody2D")
		if player_body:
			start_chasing() # Start the boss behavior
		else:
			printerr("Could not find CharacterBody2D in player node")

	# Store the original modulate color of the AnimatedSprite2D (Removed as visual aids are removed)
	# if animated_sprite:
	# 	original_modulate = animated_sprite.modulate
	# else:
	# 	printerr("Could not find AnimatedSprite2D node. Please ensure it's a child and named 'AnimatedSprite2D'.")


func _create_timer(one_shot: bool) -> Timer:
	var timer = Timer.new()
	add_child(timer) # Add timer as a child to ensure it's processed
	timer.one_shot = one_shot
	return timer

func _physics_process(_delta):
	# Movement logic only applies during the 'chasing' state
	if state == "chasing" and player_body:
		# Calculate direction to player
		var direction = (player_body.global_position - global_position).normalized()
		# Move toward player
		velocity = direction * move_speed
		move_and_slide()
	else:
		velocity = Vector2.ZERO # Stop movement in other states


func start_chasing():
	state = "chasing"
	set_attack_area_enabled(false) # Disable attack area
	# blink_timer.stop() # Stop any blinking (Removed visual aids)
	# if animated_sprite:
	# 	animated_sprite.modulate = original_modulate # Reset sprite color to original (Removed visual aids)
	movement_timer.start(chase_duration) # Start timer for chasing phase

func start_windup():
	state = "winding_up"
	set_attack_area_enabled(false) # Disable attack area
	# blink_timer.start(blink_interval_windup) # Start fast blinking (Removed visual aids)
	windup_timer.start(attack_windup_duration) # Start timer for wind-up phase

func start_attack():
	state = "attacking"
	set_attack_area_enabled(true) # Enable attack area
	# blink_timer.stop() # Stop blinking during attack (Removed visual aids)
	# if animated_sprite:
	# 	animated_sprite.modulate = original_modulate # Reset sprite color to original (Removed visual aids)
	attack_timer.start(attack_duration) # Start timer for attack phase

func start_vulnerable():
	state = "vulnerable"
	#set_attack_area_enabled(false) # Disable attack area
	# blink_timer.start(blink_interval_vulnerable) # Start slow blinking (Removed visual aids)
	vulnerable_timer.start(vulnerable_duration) # Start timer for vulnerable phase


# Timer timeout functions to transition between states
func _on_movement_timeout():
	start_windup()

func _on_windup_timeout():
	start_attack()

func _on_attack_timeout():
	start_vulnerable()

func _on_vulnerable_timeout():
	start_chasing()

# Blinking logic for AnimatedSprite2D (Removed as visual aids are removed)
# func _on_blink_timeout():
# 	if animated_sprite:
# 		if state == "winding_up" or state == "vulnerable":
# 			# Toggle modulate color between original and a darker version
# 			if animated_sprite.modulate == original_modulate:
# 				animated_sprite.modulate = Color(original_modulate.r * 0.5, original_modulate.g * 0.5, original_modulate.b * 0.5, original_modulate.a)
# 			else:
# 				animated_sprite.modulate = original_modulate
# 			# Restart blink timer with appropriate interval for current state
# 			blink_timer.start(blink_interval_windup if state == "winding_up" else blink_interval_vulnerable)


# Collision detection for attack area
func _on_attack_area_entered(area: Area2D):
	if area.is_in_group("player") and state == "attacking":
		deal_damage()
	# Only take damage if the boss is in the "vulnerable" state and hit by a weapon
	if area.is_in_group("weapon") and not shield and state == "vulnerable":
		takeDamage()

func _on_attack_body_entered(body: Node2D):
	if body.is_in_group("player") and state == "attacking":
		deal_damage()
	# Only take damage if the boss is in the "vulnerable" state and hit by a weapon
	if body.is_in_group("weapon") and not shield and state == "vulnerable":
		takeDamage()

# Function to enable/disable the attack area
func set_attack_area_enabled(enabled: bool):
	# Using set_deferred to avoid issues with physics engine updates
	attack_area.set_deferred("monitorable", enabled)
	attack_area.set_deferred("monitoring", enabled)

# Function to deal damage to the player
func deal_damage():
	GameManager.takeDamage(attack_damage)
	set_attack_area_enabled(false) # Disable attack area after dealing damage to prevent multiple hits

# Function called when a generator is destroyed (presumably from an external source)
func on_destroy_gen():
	brokenGen += 1
	print("Se rompieron " + str(brokenGen) + " gens")
	if brokenGen == 2:
		if shield:
			shield.queue_free() # Destroy the shield
			print("ADIOS ESCUDOS")

# Function to handle damage taken by the boss
func takeDamage():
	if health <= 0:
		queue_free() # Remove the boss if health is zero or less
	else:
		health -= GameManager.playerDamage # Reduce health by player's damage
		print(health)
		if health <= 0:
			# Instantiate confetti particles upon boss defeat
			var particle_scene = load("res://Scenes/Particles/confetti.tscn")
			var particles_instance = particle_scene.instantiate()
			var particles = particles_instance.get_node("GPUParticles2D")
			get_parent().add_child(particles_instance)
			particles.emitting = true
			particles.restart()
