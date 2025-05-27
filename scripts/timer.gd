extends Node2D

var segundos = GameManager.Segundos + GameManager.extra_time
@export var hp_full: Texture
@export var hp_80: Texture
@export var hp_60: Texture
@export var hp_40: Texture
@export var hp_20: Texture
@export var hp_dead: Texture

@onready var barra: TextureProgressBar = $TextureProgressBar
@onready var timer: Timer = $Timer
@onready var box_Sprite: Sprite2D = $Sprite2D
@onready var botellaCounter: RichTextLabel = $RichTextLabel
@onready var botella: Sprite2D = $botella

var is_scene_change_in_progress: bool = false  # State variable to track scene change
var Max_Segundos
var current_bottles = 0

#variables para shaders
var wave_amplitude : float = 1
var aberration : float = 0
var glitch : float = 0

var box_speed = 0
var box_aberration = 0

func _ready() -> void:
	var SceneManager = get_parent().get_parent()
	barra.max_value = SceneManager.segundos
	box_Sprite.texture = hp_full
	Max_Segundos = segundos
	updateBar()

func _process(_delta: float) -> void:
	updateBar()
	if GameManager.Segundos <= 0 and not is_scene_change_in_progress:  # Check if scene change is in progress
		is_scene_change_in_progress = true  # Set the state to indicate a scene change is in progress
		var parent = get_parent()
		var grandparent = parent.get_parent()
		grandparent.game_over()  # Call the scene change

func _on_timer_timeout() -> void:
	if GameManager.Segundos > 0:
		GameManager.Segundos -= 1

func updateBar() -> void:
	var SceneManager = get_parent().get_parent()
	botellaCounter.text = ("X " + str(SceneManager.bottleTotal - SceneManager.bottleNum))
	if SceneManager.allBottles == true:
		botellaCounter.text = ("X " + str(SceneManager.bottleTotal - SceneManager.bottleNum) + "!")
	if Max_Segundos < GameManager.Segundos:
		Max_Segundos = GameManager.Segundos
		barra.max_value = GameManager.Segundos
	barra.value = GameManager.Segundos
	if current_bottles < SceneManager.bottleNum:
		current_bottles = SceneManager.bottleNum
		wave_amplitude += 1
		aberration += 0.1
		glitch += 0.1
		botella.material.set_shader_parameter("wave_amplitude", wave_amplitude)
		botella.material.set_shader_parameter("aberration_speed", aberration)
		botella.material.set_shader_parameter("glitch_intensity", glitch)

	var porcentaje = (GameManager.Segundos / float(barra.max_value)) * 100

	if porcentaje >= 80:
		box_Sprite.texture = hp_full
		box_speed = 0
		box_aberration = 0
		box_Sprite.material.set_shader_parameter("wave_speed", box_speed)
		box_Sprite.material.set_shader_parameter("aberration_speed", box_aberration)
	elif porcentaje >= 60:
		box_Sprite.texture = hp_80
		box_speed = 0.83
		box_aberration = 0.33
		box_Sprite.material.set_shader_parameter("wave_speed", box_speed)
		box_Sprite.material.set_shader_parameter("aberration_speed", box_aberration)
	elif porcentaje >= 40:
		box_Sprite.texture = hp_60
		box_speed = 0.83*2
		box_aberration = 0.33*2
		box_Sprite.material.set_shader_parameter("wave_speed", box_speed)
		box_Sprite.material.set_shader_parameter("aberration_speed", box_aberration)
	elif porcentaje >= 20:
		box_Sprite.texture = hp_40
		box_speed = 0.83*3
		box_aberration = 0.33*3
		box_Sprite.material.set_shader_parameter("wave_speed", box_speed)
		box_Sprite.material.set_shader_parameter("aberration_speed", box_aberration)
	elif porcentaje > 0:
		box_Sprite.texture = hp_20
		box_speed = 0.83*4
		box_aberration = 0.33*4
		box_Sprite.material.set_shader_parameter("wave_speed", box_speed)
		box_Sprite.material.set_shader_parameter("aberration_speed", box_aberration)
	else:
		box_Sprite.texture = hp_dead
		box_speed = 0.83*5
		box_aberration = 0.33*5
		box_Sprite.material.set_shader_parameter("wave_speed", box_speed)
		box_Sprite.material.set_shader_parameter("aberration_speed", box_aberration)

func wait_seconds(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout

func stop_timer() -> void:
	print("time has stopped!")
	timer.stop()
	
func start_timer() -> void:
	print("time has resumed!")
	timer.start()
