extends Node2D

@onready var background: TextureRect = $Background
@onready var text_label: RichTextLabel = $Background/Text
@onready var portrait: TextureRect = $Background/Portrait
@onready var voice_player: AudioStreamPlayer2D = $VoicePlayer
@onready var scene_manager: Node = get_node("/root/Node2D2/Scene Manager")
@onready var animatic_sprite: AnimatedSprite2D = scene_manager.get_node("Pablo")

var pause_frames := [10, 22, 35, 49, 65, 76]
var is_waiting_for_frame := false

var current_lines: Array[String] = []
var current_line_index: int = 0
var is_visible: bool = false
var current_npc: Node = null
var tween: Tween
var original_y: float
var voice_timer: Timer
var current_voice: AudioStream
var pablo_condicional: bool = true

const MOVE_OFFSET: float = 500
const ANIM_DURATION: float = 0.3
const CHARACTER_DISPLAY_SPEED: float = 0.05  # Seconds per character

func _ready() -> void:
	original_y = position.y
	# Initialize hidden state
	hide_dialogue()
	
	# Setup voice timer
	voice_timer = Timer.new()
	add_child(voice_timer)
	voice_timer.timeout.connect(_play_voice_sound)
	text_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	text_label.size_flags_vertical = Control.SIZE_EXPAND_FILL

func start_dialogue(lines: Array[String], portrait_texture: Texture, npc: Node, voice_res: AudioStream = null) -> void:
	# If different NPC, completely reset dialogue
	if current_npc != npc:
		current_npc = npc
		current_lines = lines
		current_line_index = 0
		portrait.texture = portrait_texture
		current_voice = voice_res
		show_dialogue()
	# Same NPC interactions
	else:
		if is_visible:
			# If showing last line, hide and reset to last line
			if current_line_index >= current_lines.size() - 1:
				hide_dialogue()
				current_line_index = current_lines.size() - 1  # Set to last line
				return
			else:
				current_line_index += 1
		else:
			# If starting new dialogue with same NPC (after completion)
			current_line_index = current_lines.size() - 1  # Show last line
			show_dialogue()
	
	_display_current_line()

func play_jump_and_switch():
	var scene_manager = get_node("/root/Node2D2/Scene Manager")
	var milo_jump = scene_manager.get_node("MiloJump")
	var milo = scene_manager.get_node("Milo")

	milo.visible = false
	milo_jump.visible = true
	milo_jump.play("default")

	if milo_jump.animation_finished.is_connected(_on_jump_finished):
		milo_jump.animation_finished.disconnect(_on_jump_finished)

	milo_jump.animation_finished.connect(_on_jump_finished.bind(milo, milo_jump), Object.CONNECT_ONE_SHOT)

func _on_jump_finished(milo: AnimatedSprite2D, milo_jump: AnimatedSprite2D):
	milo_jump.visible = false
	milo.visible = true


var has_played_final_dialogue := false

func start_alternating_dialogue(
	lines: Array[String],
	npc: Node,
	portrait1: Texture2D, voice1: AudioStream,
	portrait2: Texture2D, voice2: AudioStream,
	portrait3: Texture2D, voice3: AudioStream
):
	if current_npc != npc or not is_visible:
		current_npc = npc
		current_lines = lines
		current_line_index = 0
		has_played_final_dialogue = false
		show_dialogue()
	else:
		if is_visible:
			if current_line_index >= current_lines.size() - 1:
				if not has_played_final_dialogue:
					has_played_final_dialogue = true
					current_line_index = current_lines.size() - 1
				else:
					current_line_index = current_lines.size() - 1
			else:
				current_line_index += 1
		else:
	
			current_line_index = current_lines.size() - 1
			show_dialogue()

	
	if current_line_index == current_lines.size() - 1:
		portrait.texture = portrait3
		current_voice = voice3
		if not has_played_final_dialogue:
			play_jump_and_switch()
	elif current_line_index % 2 == 0:
		portrait.texture = portrait1
		current_voice = voice1
	else:
		portrait.texture = portrait2
		current_voice = voice2

	_display_current_line()





func _input(event: InputEvent) -> void:
	if not is_visible: return
	
	if (event.is_action_pressed("ui_up") ||
		event.is_action_pressed("ui_down") ||
		event.is_action_pressed("ui_left") ||
		event.is_action_pressed("ui_right")
		):
		player_moved()

func player_moved() -> void:
	if pablo_condicional:
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
		var interval = max(0.1, typewriter_duration / line_length)
		voice_timer.start(interval)
	
	# Animate text display
	var typewriter_tween = create_tween()
	typewriter_tween.tween_property(text_label, "visible_ratio", 1.0, typewriter_duration)
	typewriter_tween.tween_callback(voice_timer.stop)

func _play_voice_sound() -> void:
	if current_voice:
		voice_player.pitch_scale = randf_range(0.95, 1.05)
		voice_player.play()

func show_dialogue() -> void:
	if tween:
		tween.kill()
	
	# Ensure we're starting from below screen
	position.y = original_y + MOVE_OFFSET
	visible = true
	is_visible = true
	set_process_input(true)
	
	# Animate up
	tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position:y", original_y, ANIM_DURATION)

func hide_dialogue(instant: bool = false) -> void:
	if not is_visible: return
	
	if tween:
		tween.kill()
	
	is_visible = false
	set_process_input(false)
	voice_timer.stop()
	
	if instant:
		position.y = original_y + MOVE_OFFSET
		visible = false
	else:
		# Animate down
		tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		tween.tween_property(self, "position:y", original_y + MOVE_OFFSET, ANIM_DURATION)
		tween.tween_callback(func(): 
			visible = false
			position.y = original_y + MOVE_OFFSET  # Ensure final position
		)

func start_auto_dialogue(lines: Array[String], portrait_texture: Texture, npc: Node, voice_res: AudioStream = null) -> void:
	current_npc = npc
	current_lines = lines
	current_line_index = 0
	portrait.texture = portrait_texture
	current_voice = voice_res
	show_dialogue()
	_display_auto_line()

func _display_auto_line() -> void:
	var scene_manager = get_node("/root/Node2D2/Scene Manager")
	var puerta = scene_manager.get_node("Puerta")
	var colision = puerta.get_node("StaticBody2D/CollisionShape2D")
	text_label.visible_ratio = 0
	text_label.text = current_lines[current_line_index]
	if pablo_condicional:
		puerta.visible = true
		puerta.play("default")
		colision.set_deferred("disabled", false)
	pablo_condicional = false
	

	voice_timer.stop()
	var line_length = current_lines[current_line_index].length()
	var typewriter_duration = CHARACTER_DISPLAY_SPEED * line_length

	if current_voice and line_length > 0:
		voice_player.stream = current_voice
		var interval = max(0.1, typewriter_duration / line_length)
		voice_timer.start(interval)

	var tween = create_tween()
	tween.tween_property(text_label, "visible_ratio", 1.0, typewriter_duration)
	tween.tween_callback(voice_timer.stop)

	tween.tween_callback(func() -> void:
		await get_tree().create_timer(1.2).timeout

		if current_line_index == 0:
			play_walking()
			# Empezar a observar los frames
			animatic_sprite.frame_changed.connect(_on_animatic_frame, CONNECT_DEFERRED)

		if current_line_index < current_lines.size() - 1:
			current_line_index += 1
			is_waiting_for_frame = true
		else:
			await get_tree().create_timer(2.0).timeout
			animatic_sprite.frame_changed.disconnect(_on_animatic_frame)
			hide_dialogue()
	)

func _on_animatic_frame():
	if not is_waiting_for_frame:
		return

	if pause_frames.has(animatic_sprite.frame):
		is_waiting_for_frame = false
		animatic_sprite.pause()
		_display_auto_line()
		await get_tree().create_timer(1.2).timeout
		animatic_sprite.play()


	
func play_walking():
	var scene_manager = get_node("/root/Node2D2/Scene Manager")
	var pablo_intro = scene_manager.get_node("Pablo")
	var pablo_seVa = scene_manager.get_node("PabloSeVa")
	pablo_condicional = false
	

	pablo_seVa.visible = false
	pablo_intro.visible = true
	pablo_intro.play("default")
	

	if pablo_intro.animation_finished.is_connected(_disapear):
		pablo_intro.animation_finished.disconnect(_disapear)

	pablo_intro.animation_finished.connect(_disapear.bind(pablo_seVa, pablo_intro), Object.CONNECT_ONE_SHOT)

func _disapear(pablo_seVa: AnimatedSprite2D, pablo_intro: AnimatedSprite2D):
	var scene_manager = get_node("/root/Node2D2/Scene Manager")
	var puerta = scene_manager.get_node("Puerta")
	var colision = puerta.get_node("StaticBody2D/CollisionShape2D")
	pablo_intro.visible = false
	pablo_seVa.visible = true
	pablo_seVa.play("default")
	pablo_condicional = true
	colision.set_deferred("disabled", true)
	puerta.play("desaparece")
	hide_dialogue()
