extends Node2D

@onready var background: TextureRect = $Background
@onready var text_label: RichTextLabel = $Background/Text
@onready var portrait: TextureRect = $Background/Portrait

var current_lines: Array[String] = []
var current_line_index: int = 0
var is_visible: bool = false
var current_npc: Node = null
var tween: Tween
var original_y: float

const MOVE_OFFSET: float = 500
const ANIM_DURATION: float = 0.3

func _ready() -> void:
	original_y = position.y
	# Start hidden (without animation)
	visible = false
	position.y = original_y + MOVE_OFFSET
	set_process_input(false)

func start_dialogue(lines: Array[String], portrait_texture: Texture, npc: Node) -> void:
	# If different NPC, completely reset dialogue
	if current_npc != npc:
		current_npc = npc
		current_lines = lines
		current_line_index = 0
		portrait.texture = portrait_texture
		show_dialogue()
		_display_current_line()
		return
	
	# Same NPC interactions
	if is_visible:
		# If showing last line, hide and reset
		if current_line_index >= current_lines.size() - 1:
			hide_dialogue()
			current_line_index = 0
		# Otherwise advance to next line
		else:
			current_line_index += 1
			_display_current_line()
	else:
		# Start dialogue from current position
		show_dialogue()
		_display_current_line()

func _input(event: InputEvent) -> void:
	if not is_visible: return
	
	if _is_movement_input(event):
		player_moved()

func _is_movement_input(event: InputEvent) -> bool:
	return (
		event.is_action_pressed("ui_up") ||
		event.is_action_pressed("ui_down") ||
		event.is_action_pressed("ui_left") ||
		event.is_action_pressed("ui_right")
	)

func player_moved() -> void:
	hide_dialogue()

func _display_current_line() -> void:
	text_label.visible_ratio = 0
	text_label.text = current_lines[current_line_index]
	
	# Typewriter effect
	var typewriter_tween = create_tween()
	typewriter_tween.tween_property(text_label, "visible_ratio", 1.0, 
		0.05 * current_lines[current_line_index].length())

func show_dialogue() -> void:
	if tween:
		tween.kill()
	
	is_visible = true
	visible = true
	set_process_input(true)
	
	# Always animate when showing (starting from below screen)
	position.y = original_y + MOVE_OFFSET
	tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position:y", original_y, ANIM_DURATION)

func hide_dialogue() -> void:
	if not is_visible: return
	
	if tween:
		tween.kill()
	
	is_visible = false
	set_process_input(false)
	
	tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "position:y", original_y + MOVE_OFFSET, ANIM_DURATION)
	tween.tween_callback(func(): visible = false)
