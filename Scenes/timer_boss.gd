extends Node2D

@onready var healthbar : TextureProgressBar = $TextureProgressBar
@export var boss : CharacterBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	healthbar.max_value = boss.health
	healthbar.value = boss.health

func damage():
	healthbar.value = boss.health
