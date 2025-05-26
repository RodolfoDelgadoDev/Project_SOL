extends Node2D

@onready var background: TextureRect = $Background
@onready var text_label: RichTextLabel = $Background/Text
@onready var portrait: TextureRect = $Background/Portrait
@onready var voice_player: AudioStreamPlayer2D = $VoicePlayer

var current_lines: Array[String] = []
var current_line_index: int = 0
var es_visible: bool = false
var current_npc: Node = null
var tween: Tween
var original_y: float
var voice_timer: Timer
var current_voice: AudioStream

const MOVE_OFFSET: float = 500
const ANIM_DURATION: float = 0.3
const CHARACTER_DISPLAY_SPEED: float = 0.05  # Seconds per character

func _ready() -> void:
	original_y = position.y
	# Initialize hidden state
	visible = false
	position.y = original_y + MOVE_OFFSET
	set_process_input(false)
	
	# Setup voice timer
	voice_timer = Timer.new()
	add_child(voice_timer)
	voice_timer.timeout.connect(_play_voice_sound)

func start_dialogue(lines: Array[String], portrait_texture: Texture, npc: Node, voice_res: AudioStream = null) -> void:
	# If different NPC, completely reset dialogue
	if current_npc != npc:
		current_npc = npc
		current_lines = lines
		current_line_index = 0
		portrait.texture = portrait_texture
		current_voice = voice_res
		show_dialogue()  # This will animate in
	# Same NPC interactions
	else:
		if is_visible:
			# If showing last line, hide and reset
			if current_line_index >= current_lines.size() - 1:
				hide_dialogue()
				current_line_index = 0
				return
			# Otherwise advance to next line
			else:
				current_line_index += 1
		else:
			# If starting new dialogue with same NPC (after completion)
			if current_line_index >= current_lines.size():
				current_line_index = 0  # Reset if we had completed before
			show_dialogue()  # This will animate in
	
	_display_current_line()

func _input(event: InputEvent) -> void:
	if not is_visible: return
	
	if (event.is_action_pressed("ui_up") ||
		event.is_action_pressed("ui_down") ||
		event.is_action_pressed("ui_left") ||
		event.is_action_pressed("ui_right")):
		player_moved()

func player_moved() -> void:
	hide_dialogue()

func _display_current_line() -> void:
	# Setup text display
	text_label.visible_ratio = 0
	text_label.text = current_lines[current_line_index]
	
	# Stop any ongoing voice sounds
	voice_timer.stop()
	
	# Calculate typewriter effect duration
	var line_length = current_lines[current_line_index].length()
	var typewriter_duration = CHARACTER_DISPLAY_SPEED * line_length
	
	# Setup voice playback if available
	if current_voice and line_length > 0:
		voice_player.stream = current_voice
		var interval = max(0.1, typewriter_duration / line_length)  # Minimum 0.1s between sounds
		voice_timer.start(interval)
	
	# Animate text display
	var typewriter_tween = create_tween()
	typewriter_tween.tween_property(text_label, "visible_ratio", 1.0, typewriter_duration)
	typewriter_tween.tween_callback(voice_timer.stop)

func _play_voice_sound() -> void:
	if current_voice:
		voice_player.pitch_scale = randf_range(0.95, 1.05)  # Slight variation
		voice_player.play()

func show_dialogue() -> void:
	if tween:
		tween.kill()
	
	es_visible = true
	visible = true
	set_process_input(true)
	
	# Animate from below screen
	position.y = original_y + MOVE_OFFSET
	tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position:y", original_y, ANIM_DURATION)

func hide_dialogue() -> void:
	if not is_visible: return
	
	if tween:
		tween.kill()
	
	es_visible = false
	set_process_input(false)
	voice_timer.stop()
	
	# Animate down below screen
	tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "position:y", original_y + MOVE_OFFSET, ANIM_DURATION)
	tween.tween_callback(func(): visible = false)
