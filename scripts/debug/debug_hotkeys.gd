extends Node
## Autoload de debug: F1 abre el editor de guardado desde cualquier pantalla.
## Solo actúa en builds de debug (correr desde el editor cuenta como debug).
## En un build exportado de release no hace nada.
## Para quitarlo: borrá este autoload en Proyecto > Configuración del proyecto > Globales.

const SAVE_EDITOR_SCENE := "res://Scenes/Debug/SaveEditor.tscn"
const OPEN_KEY := KEY_F1


func _ready() -> void:
	# Tiene que seguir escuchando aunque el juego esté en pausa
	process_mode = Node.PROCESS_MODE_ALWAYS
	if not OS.is_debug_build():
		set_process_input(false)


func _input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo and event.keycode == OPEN_KEY):
		return
	var current := get_tree().current_scene
	if current != null and current.scene_file_path == SAVE_EDITOR_SCENE:
		return
	get_viewport().set_input_as_handled()
	get_tree().paused = false
	get_tree().change_scene_to_file(SAVE_EDITOR_SCENE)
