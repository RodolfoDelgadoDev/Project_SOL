extends Node2D

@export var animaciones : Array[AnimatedSprite2D]
var index_anim = 0
var esperando_input = false
@export var popup : ColorRect

func _ready() -> void:
	avanzar()
	

func _input(event: InputEvent) -> void:
	if esperando_input and event.is_action_pressed("ui_accept"):
		# Si el personaje tiene diálogo y quedan líneas, el espacio solo avanza el diálogo
		var caja = _buscar_caja_de_dialogo(animaciones[index_anim])
		if caja and caja.hay_mas_lineas():
			caja.mostrar_siguiente_linea()
		else:
			esperando_input = false

# Devuelve el dialogue box visible que tenga la animación adentro, o null si no tiene
func _buscar_caja_de_dialogo(animacion: Node) -> Node:
	for hijo in animacion.get_children():
		if hijo.has_method("mostrar_siguiente_linea") and hijo.visible:
			return hijo
	return null

func avanzar():
	while index_anim < animaciones.size():
		var animacion_actual = animaciones[index_anim]
		# La primera línea queda lista antes de que aparezca la animación
		var caja = _buscar_caja_de_dialogo(animacion_actual)
		if caja:
			caja.mostrar_siguiente_linea()
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
		# Si se salteó a mitad de línea, que no siga sonando la voz de esta caja
		if caja:
			caja.detener()
		animacion_actual.visible = false
		index_anim += 1
	get_tree().change_scene_to_file("res://Scenes/Levels/Bossfight.tscn")
