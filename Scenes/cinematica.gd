extends Node2D

@export var animaciones : Array[AnimatedSprite2D]
var index_anim = 0
var esperando_input = false
@export var popup : ColorRect

func _ready() -> void:
	popup.appear()
	avanzar()

func _input(event: InputEvent) -> void:
	if esperando_input and event.is_action_pressed("ui_accept"):
		esperando_input = false

func avanzar():
	while index_anim < animaciones.size():
		var animacion_actual = animaciones[index_anim]
		animacion_actual.visible = true
		var tween = create_tween()
		tween.tween_property(animacion_actual, "modulate:a", 0, 0)
		tween.tween_property(animacion_actual, "modulate:a", 1, 1.0)
		await tween.finished
		animacion_actual.play()
		esperando_input = true
		while esperando_input:
			await get_tree().process_frame
		animacion_actual.stop()
		animacion_actual.visible = false
		index_anim += 1
	get_tree().change_scene_to_file("res://Scenes/Levels/Bossfight.tscn")
