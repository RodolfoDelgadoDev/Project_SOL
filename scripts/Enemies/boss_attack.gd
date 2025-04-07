extends CharacterBody2D

@export var move_speed: float = 100.0
@export var chase_duration: float = 2.0
@export var attack_windup_duration: float = 1.5
@export var blink_interval: float = 0.1
@export var attack_duration: float = 3.0
@export var attack_damage: float = 10.0
@export var player_node: Node2D

@onready var colorRect: ColorRect = $ColorRect
@onready var attack_area: Area2D = $Area2D

var player_body: CharacterBody2D = null
var is_chasing: bool = false
var is_winding_up: bool = false
var is_attacking: bool = false
var movement_timer: Timer = null
var windup_timer: Timer = null
var blink_timer: Timer = null
var attack_timer: Timer = null

func _ready():
	# Initialize all timers
	movement_timer = _create_timer(true)
	windup_timer = _create_timer(true)
	blink_timer = _create_timer(false)
	attack_timer = _create_timer(true)
	
	movement_timer.timeout.connect(_on_movement_timeout)
	windup_timer.timeout.connect(_on_windup_timeout)
	blink_timer.timeout.connect(_on_blink_timeout)
	attack_timer.timeout.connect(_on_attack_timeout)
	
	# Connect area signals
	attack_area.area_entered.connect(_on_attack_area_entered)
	attack_area.body_entered.connect(_on_attack_body_entered)
	
	# Find player's CharacterBody2D
	if player_node:
		player_body = player_node.get_node("CharacterBody2D")
		if player_body:
			start_chasing()
		else:
			printerr("Could not find CharacterBody2D in player node")

func _create_timer(one_shot: bool) -> Timer:
	var timer = Timer.new()
	add_child(timer)
	timer.one_shot = one_shot
	return timer

func _physics_process(delta):
	if not is_chasing or not player_body or is_winding_up or is_attacking:
		return
	
	# Calculate direction to player
	var direction = (player_body.global_position - global_position).normalized()
	
	# Move toward player
	velocity = direction * move_speed
	move_and_slide()

func start_chasing():
	colorRect.color = Color(1, 0, 0, 0.5)  # Red when chasing
	set_attack_area_enabled(false)
	is_chasing = true
	is_winding_up = false
	is_attacking = false
	colorRect.visible = true
	movement_timer.start(chase_duration)

func start_windup():
	set_attack_area_enabled(false)
	is_chasing = false
	is_winding_up = true
	is_attacking = false
	velocity = Vector2.ZERO
	colorRect.visible = false
	blink_timer.start(blink_interval)
	windup_timer.start(attack_windup_duration)

func start_attack():
	colorRect.color = Color(0, 0, 1, 0.5)  # Blue when attacking
	set_attack_area_enabled(true)
	is_chasing = false
	is_winding_up = false
	is_attacking = true
	colorRect.visible = true
	attack_timer.start(attack_duration)

func _on_movement_timeout():
	start_windup()

func _on_windup_timeout():
	start_attack()

func _on_attack_timeout():
	set_attack_area_enabled(false)
	start_chasing()

func _on_blink_timeout():
	if is_winding_up:
		colorRect.visible = !colorRect.visible
		blink_timer.start(blink_interval)

func _on_attack_area_entered(area: Area2D):
	if area.is_in_group("player") and is_attacking:
		deal_damage()

func _on_attack_body_entered(body: Node2D):
	if body.is_in_group("player") and is_attacking:
		deal_damage()

func set_attack_area_enabled(enabled: bool):
	attack_area.set_deferred("monitorable", enabled)
	attack_area.set_deferred("monitoring", enabled)

func deal_damage():
	GameManager.takeDamage(attack_damage)
	set_attack_area_enabled(false)  # Just disable the attack area without ending phase
