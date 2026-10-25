extends Node2D

@export var dialogue_lines : Array[String]
## Voz de respaldo: se usa si la línea no tiene personaje o ese personaje no tiene voces cargadas
@export var voice : AudioStream

@export_group("Voces por personaje")
## Sonidos que se repiten en orden, con pitch aleatorio, mientras habla cada personaje
@export var voces_coli : Array[AudioStream]
@export var voces_wanda : Array[AudioStream]
@export var voces_rastas : Array[AudioStream]
@export var sfx : Array[AudioStream]
@export_group("")

# Referencias exportadas (Asegúrate de arrastrarlas en el Inspector)
@export var text_label: RichTextLabel
@export var voice_player: AudioStreamPlayer2D

const PERSONAJES := ["coli", "wanda", "rastas", "sfx"]
const CHARACTER_DISPLAY_SPEED: float = 0.05  # Segundos por letra (igual que dialogue_box.gd)
const VOICE_INTERVAL: float = 0.1  # Un sonido de voz cada 0.1 s (igual que dialogue_box.gd)

var line_index := -1
var hablante := ""
var voces_actuales: Array[AudioStream] = []
var voice_index := 0
var voice_timer: Timer
var typewriter_tween: Tween

func _ready() -> void:
	voice_timer = Timer.new()
	add_child(voice_timer)
	voice_timer.timeout.connect(_play_voice_sound)
	text_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	# El scroll lo controlamos nosotros siguiendo el texto que ya se escribió
	text_label.scroll_following = false

func hay_mas_lineas() -> bool:
	return line_index < dialogue_lines.size() - 1

# Muestra la siguiente línea del array (no hace nada si ya se mostró la última)
func mostrar_siguiente_linea() -> void:
	if not hay_mas_lineas():
		return
	line_index += 1
	var texto := _separar_hablante(dialogue_lines[line_index])
	voces_actuales = _voces_del_hablante()

	text_label.text = texto
	text_label.visible_ratio = 0
	text_label.scroll_to_line(0)

	var duracion := CHARACTER_DISPLAY_SPEED * texto.length()
	if not voces_actuales.is_empty() and texto.length() > 0:
		voice_timer.start(VOICE_INTERVAL)
	else:
		voice_timer.stop()

	# Un solo efecto de escritura a la vez, si no el de la línea anterior pisaría al nuevo
	if typewriter_tween and typewriter_tween.is_valid():
		typewriter_tween.kill()
	typewriter_tween = create_tween()
	typewriter_tween.tween_method(_set_text_progress, 0.0, 1.0, duracion)
	typewriter_tween.tween_callback(voice_timer.stop)

# Corta la escritura y el sonido (para cuando la animación del personaje termina)
func detener() -> void:
	if typewriter_tween and typewriter_tween.is_valid():
		typewriter_tween.kill()
	voice_timer.stop()
	voice_player.stop()

# Si la línea empieza con [Coli], [Wanda] o [Rastas] cambia el hablante y devuelve el texto sin la etiqueta
func _separar_hablante(linea: String) -> String:
	var minuscula := linea.to_lower()
	for nombre: String in PERSONAJES:
		var etiqueta: String = "[" + nombre + "]"
		if minuscula.begins_with(etiqueta):
			hablante = nombre
			return linea.substr(etiqueta.length()).strip_edges()
	return linea

func _voces_del_hablante() -> Array[AudioStream]:
	var voces: Array[AudioStream] = []
	match hablante:
		"coli":
			voces = voces_coli
		"wanda":
			voces = voces_wanda
		"rastas":
			voces = voces_rastas
		"sfx":
			voces = sfx
	if voces.is_empty() and voice:
		voces = [voice]
	return voces

func _play_voice_sound() -> void:
	if voces_actuales.is_empty():
		return
	voice_player.stream = voces_actuales[voice_index % voces_actuales.size()]
	voice_index += 1
	voice_player.pitch_scale = randf_range(0.95, 1.05)
	voice_player.play()

func _set_text_progress(ratio: float) -> void:
	text_label.visible_ratio = ratio
	_follow_typed_text()

# Mueve el scroll para que la última letra escrita siempre quede dentro de la caja
func _follow_typed_text() -> void:
	var typed: int = text_label.visible_characters
	if typed < 0:
		typed = text_label.get_total_character_count()
	if typed <= 0:
		return
	var last_line: int = text_label.get_character_line(typed - 1)
	var bottom: float
	if last_line + 1 < text_label.get_line_count():
		bottom = text_label.get_line_offset(last_line + 1)
	else:
		bottom = text_label.get_content_height()
	# Primera línea que podemos mostrar arriba sin que la última se salga por abajo
	var top_line: int = 0
	while top_line < last_line and bottom - text_label.get_line_offset(top_line) > text_label.size.y:
		top_line += 1
	text_label.scroll_to_line(top_line)
