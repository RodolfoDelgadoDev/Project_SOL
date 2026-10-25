extends Node2D

# Array of dialogue sets for each level (1-8)
@export var dialogue_lines1: Array[String] = []
@export var dialogue_lines2: Array[String] = []
@export var dialogue_lines3: Array[String] = []
@export var dialogue_lines4: Array[String] = []
@export var dialogue_lines5: Array[String] = []
@export var dialogue_lines6: Array[String] = []
@export var dialogue_lines7: Array[String] = []
@export var dialogue_lines8: Array[String] = []

@export var npc_portrait: Texture2D
@export var dialogue_manager: Node2D
@export var voice_sound: AudioStream
@export var sprite: Texture

@export var nuevo_bate : bool = false

# true  = aparece solo si el poder YA fue entregado (WandaV2)
# false = aparece solo si el poder NO fue entregado todavía (Wanda original)
# Dejalo en "Mostrar Siempre" para NPCs que no usan esta lógica
@export var usar_visibilidad_por_poder: bool = false
@export var visible_si_entregado: bool = false

@onready var sprite2D: Sprite2D = get_node_or_null("Sprite2D")
# El AnimatedSprite2D es el nodo padre de este script (ej: Wanda)
@onready var animated_sprite: AnimatedSprite2D = get_parent() as AnimatedSprite2D

# Bandera interna para saber si estábamos conversando con este NPC
var _was_in_dialogue: bool = false
var _animando: bool = false

func _ready():
	if sprite2D and sprite:
		sprite2D.texture = sprite
	if animated_sprite:
		animated_sprite.stop()
		animated_sprite.frame = 0

	if usar_visibilidad_por_poder:
		_aplicar_visibilidad()

func _aplicar_visibilidad() -> void:
	var activo: bool = (GameManager.bate_entregado == visible_si_entregado)
	# Si el sprite animado es el padre (Wanda original), se oculta el padre; si no, este nodo
	var objetivo: Node2D = animated_sprite if animated_sprite else self
	objetivo.visible = activo
	objetivo.process_mode = Node.PROCESS_MODE_INHERIT if activo else Node.PROCESS_MODE_DISABLED

func get_dialogue_for_current_level() -> Array[String]:
	match GameManager.levelNumber:
		1: return dialogue_lines1
		2: return dialogue_lines2
		3: return dialogue_lines3
		4: return dialogue_lines4
		5: return dialogue_lines5
		6: return dialogue_lines6
		7: return dialogue_lines7
		8: return dialogue_lines8
		_: return dialogue_lines1  # Default fallback

func _on_area_2d_area_shape_entered(_area_rid: RID, area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	if not is_visible_in_tree():
		return
	if area.is_in_group("weapon"):
		var current_dialogue = get_dialogue_for_current_level()
		if current_dialogue.size() > 0:  # Only start if there's dialogue
			_was_in_dialogue = true
			dialogue_manager.start_dialogue(
				current_dialogue,
				npc_portrait,
				self,
				voice_sound
			)

func powerup():
	GameManager.playerDamage = 15
	GameManager.bate_entregado = true
	var SceneManager = self.get_parent().get_parent()
	SceneManager.powerup()

# Reproduce la animación una vez, vuelve al primer frame y recién ahí activa el poder
func _animar_y_powerup() -> void:
	if _animando:
		return
	_animando = true
	if animated_sprite and animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation("default"):
		animated_sprite.play("default")
		await animated_sprite.animation_finished
		animated_sprite.stop()
		animated_sprite.frame = 0
	_animando = false
	powerup()

# Verificamos por frame si el diálogo se cerró para ejecutar la animación y el powerup
func _process(_delta: float) -> void:
	if _was_in_dialogue:
		# Verificamos si el dialogue_manager ya ocultó la caja o cambió de NPC actual
		if dialogue_manager.current_npc != self or not dialogue_manager.es_visible:
			_was_in_dialogue = false
			if nuevo_bate:
				_animar_y_powerup()
