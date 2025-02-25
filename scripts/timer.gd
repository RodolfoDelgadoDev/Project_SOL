extends Node2D

var segundos = GameManager.Segundos
@export var hp_full : Texture
@export var hp_80 : Texture
@export var hp_60 : Texture
@export var hp_40 : Texture
@export var hp_20 : Texture
@export var hp_dead : Texture

@onready var barra: TextureProgressBar = $TextureProgressBar
@onready var timer: Timer = $Timer
@onready var box_Sprite : Sprite2D = $Sprite2D
@onready var botellaCounter : RichTextLabel = $RichTextLabel

func _ready() -> void:
	var SceneManager = get_parent().get_parent()
	barra.max_value = SceneManager.segundos
	updateBar()
	
func _process(_delta: float) -> void:
	updateBar()
	if GameManager.Segundos <= 0: ##This kills the player
		await wait_seconds(3)
		var parent = get_parent()
		var grandparent = parent.get_parent()
		grandparent.change_scene("res://scenes/GameOver.tscn")

func _on_timer_timeout() -> void:
	if (GameManager.Segundos > 0):
		GameManager.Segundos -=1

func updateBar() -> void:
	var SceneManager = get_parent().get_parent()
	botellaCounter.text = ("X " + str(SceneManager.bottleNum))
	if SceneManager.allBottles == true:
		botellaCounter.push_color(Color("yellow"))
		botellaCounter.text = ("X " + str(SceneManager.bottleNum))
	barra.value = GameManager.Segundos
	if GameManager.Segundos >= 80 :
		box_Sprite.texture = hp_full
	if GameManager.Segundos < 80:
		box_Sprite.texture = hp_80
		if GameManager.Segundos < 60:
			box_Sprite.texture = hp_60
			if GameManager.Segundos < 40:
				box_Sprite.texture = hp_40
				if GameManager.Segundos < 20:
					box_Sprite.texture = hp_20
					if GameManager.Segundos == 0:
						box_Sprite.texture = hp_dead
			
	
func wait_seconds(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
