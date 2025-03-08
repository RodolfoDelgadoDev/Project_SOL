extends Node2D

var segundos = GameManager.Segundos
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

var is_scene_change_in_progress: bool = false  # State variable to track scene change

func _ready() -> void:
	var SceneManager = get_parent().get_parent()
	barra.max_value = SceneManager.segundos
	box_Sprite.texture = hp_full
	updateBar()

func _process(_delta: float) -> void:
	updateBar()
	if GameManager.Segundos <= 0 and not is_scene_change_in_progress:  # Check if scene change is in progress
		is_scene_change_in_progress = true  # Set the state to indicate a scene change is in progress
		var parent = get_parent()
		var grandparent = parent.get_parent()
		grandparent.change_scene("res://Scenes/GameOverUpdate.tscn")  # Call the scene change

func _on_timer_timeout() -> void:
	if GameManager.Segundos > 0:
		GameManager.Segundos -= 1

func updateBar() -> void:
	var SceneManager = get_parent().get_parent()
	botellaCounter.text = ("X " + str(SceneManager.bottleNum))
	if SceneManager.allBottles == true:
		botellaCounter.push_color(Color("yellow"))
		botellaCounter.text = ("X " + str(SceneManager.bottleNum))
	barra.value = GameManager.Segundos

	var porcentaje = (GameManager.Segundos / float(barra.max_value)) * 100

	if porcentaje >= 80:
		box_Sprite.texture = hp_full
	elif porcentaje >= 60:
		box_Sprite.texture = hp_80
	elif porcentaje >= 40:
		box_Sprite.texture = hp_60
	elif porcentaje >= 20:
		box_Sprite.texture = hp_40
	elif porcentaje > 0:
		box_Sprite.texture = hp_20
	else:
		box_Sprite.texture = hp_dead

func wait_seconds(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout

func stop_timer() -> void:
	print("time has stopped!")
	timer.stop()
