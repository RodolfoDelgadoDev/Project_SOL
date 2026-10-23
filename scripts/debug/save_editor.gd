extends Control
## Herramienta de debug: editar el guardado y saltar a cualquier pantalla
## sin tener que empezar desde cero.
##
## Se abre con F1 desde cualquier parte del juego (ver debug_hotkeys.gd) o
## ejecutando esta escena sola con F6. Usa las mismas funciones de GameManager
## que el juego (save_game, get_descanso_scene), así que si cambia el formato
## del guardado la herramienta lo sigue sin tocar nada.

const MENU_SCENE := "res://Scenes/MainMenuUpdate.tscn"
const TUTORIAL_SCENE := "res://Scenes/Levels/Tutorial.tscn"
const REST_PATH := "res://Scenes/Levels/Descansos/descanso%d.tscn"
# Mismo orden que chooseTargetScene() en MainMenu.gd: el nivel N es LEVELS[N - 1]
const LEVELS: Array[String] = [
	"res://Scenes/Levels/edificio.tscn",
	"res://Scenes/Levels/edificio2.tscn",
	"res://Scenes/Levels/edificio3.tscn",
	"res://Scenes/Levels/complejo.tscn",
	"res://Scenes/Levels/complejo2.tscn",
	"res://Scenes/Levels/bosque.tscn",
	"res://Scenes/Levels/bosque2.tscn",
	"res://Scenes/Levels/Bossfight.tscn",
]

# Ids de las opciones del selector de destino (los niveles usan su número, 1 a 8)
const TARGET_REST := 0
const TARGET_TUTORIAL := 100
const TARGET_MENU := 101

const DESIGN_SIZE := Vector2(640, 520)
const MAX_LEVEL := 9
const MAX_COINS := 9

var ui_layer: CanvasLayer
var ui_root: Control
var level_spin: SpinBox
var coin_spin: SpinBox
var damage_spin: SpinBox
var level_hint: Label
var coin_hint: Label
var status_label: Label
var raw_label: Label
var target_option: OptionButton
var save_before_go: CheckBox
var delete_button: Button
var delete_armed := false


func _ready() -> void:
	# Por si se llegó desde un menú de pausa
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = false
	_build_ui()
	get_viewport().size_changed.connect(_fit)
	_fit()
	_load_from_file()


# ---------------------------------------------------------------- UI

func _build_ui() -> void:
	ui_layer = CanvasLayer.new()
	ui_layer.layer = 100
	add_child(ui_layer)

	ui_root = Control.new()
	ui_layer.add_child(ui_root)

	var background := ColorRect.new()
	background.color = Color(0.08, 0.08, 0.1, 1.0)
	ui_root.add_child(background)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var center := CenterContainer.new()
	ui_root.add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = DESIGN_SIZE
	center.add_child(panel)

	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 14)
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	margin.add_child(box)

	var title := Label.new()
	title.text = "EDITOR DE GUARDADO (debug)"
	title.add_theme_font_size_override("font_size", 22)
	box.add_child(title)

	status_label = Label.new()
	box.add_child(status_label)

	var path_label := Label.new()
	path_label.text = ProjectSettings.globalize_path(GameManager.SAVE_FILE_PATH)
	path_label.autowrap_mode = TextServer.AUTOWRAP_ARBITRARY
	path_label.modulate = Color(1, 1, 1, 0.55)
	box.add_child(path_label)

	box.add_child(HSeparator.new())

	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 8)
	box.add_child(grid)

	var level_field := _add_field(grid, "levelNumber", 0, MAX_LEVEL)
	level_spin = level_field[0]
	level_hint = level_field[1]
	var coin_field := _add_field(grid, "plasticoin", 0, MAX_COINS)
	coin_spin = coin_field[0]
	coin_hint = coin_field[1]
	var damage_field := _add_field(grid, "playerDamage", 0, 999)
	damage_spin = damage_field[0]
	damage_field[1].text = "Daño del jugador"
	level_spin.value_changed.connect(func(_v: float) -> void: _update_hints())
	coin_spin.value_changed.connect(func(_v: float) -> void: _update_hints())

	var file_row := HBoxContainer.new()
	file_row.add_theme_constant_override("separation", 8)
	box.add_child(file_row)
	_add_button(file_row, "Guardar", _on_save_pressed)
	_add_button(file_row, "Recargar del archivo", _load_from_file)
	delete_button = _add_button(file_row, "Borrar guardado", _on_delete_pressed)
	_add_button(file_row, "Abrir carpeta", _on_open_folder_pressed)

	raw_label = Label.new()
	raw_label.autowrap_mode = TextServer.AUTOWRAP_ARBITRARY
	raw_label.modulate = Color(1, 1, 1, 0.55)
	box.add_child(raw_label)

	box.add_child(HSeparator.new())

	var go_title := Label.new()
	go_title.text = "Ir a una pantalla (usa los valores de arriba)"
	box.add_child(go_title)

	target_option = OptionButton.new()
	target_option.add_item("Descanso según plasticoin (lo que haría Continue)", TARGET_REST)
	for i in LEVELS.size():
		target_option.add_item("Nivel %d  (%s)" % [i + 1, LEVELS[i].get_file().get_basename()], i + 1)
	target_option.add_item("Tutorial", TARGET_TUTORIAL)
	target_option.add_item("Menú principal", TARGET_MENU)
	box.add_child(target_option)

	var go_row := HBoxContainer.new()
	go_row.add_theme_constant_override("separation", 12)
	box.add_child(go_row)
	_add_button(go_row, "IR", _on_go_pressed)
	save_before_go = CheckBox.new()
	save_before_go.text = "Guardar antes de ir"
	go_row.add_child(save_before_go)

	var tip := Label.new()
	tip.text = "Al ir a un nivel directo, levelNumber pasa a ser ese nivel (como si vinieras del descanso). F1 abre esta pantalla desde cualquier lado."
	tip.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tip.modulate = Color(1, 1, 1, 0.55)
	box.add_child(tip)


func _add_field(grid: GridContainer, field_name: String, min_value: int, max_value: int) -> Array:
	var name_label := Label.new()
	name_label.text = field_name
	grid.add_child(name_label)

	var spin := SpinBox.new()
	spin.min_value = min_value
	spin.max_value = max_value
	spin.step = 1
	spin.rounded = true
	spin.custom_minimum_size.x = 120
	grid.add_child(spin)

	var hint := Label.new()
	hint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hint.modulate = Color(1, 1, 1, 0.7)
	grid.add_child(hint)
	return [spin, hint]


func _add_button(parent: Control, text: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.pressed.connect(callback)
	parent.add_child(button)
	return button


# La UI se diseña para DESIGN_SIZE y se escala para entrar en cualquier ventana
func _fit() -> void:
	var viewport_size := get_viewport_rect().size
	var ratio := clampf(minf(viewport_size.x / DESIGN_SIZE.x, viewport_size.y / DESIGN_SIZE.y), 0.2, 3.0)
	ui_layer.scale = Vector2(ratio, ratio)
	ui_root.size = viewport_size / ratio


# ---------------------------------------------------------------- Datos

func _read_save_file() -> Dictionary:
	if not FileAccess.file_exists(GameManager.SAVE_FILE_PATH):
		return {}
	var file := FileAccess.open(GameManager.SAVE_FILE_PATH, FileAccess.READ)
	if file == null:
		return {"__error": "no se pudo abrir el archivo"}
	var text := file.get_as_text()
	raw_label.text = "Archivo: " + text
	var json := JSON.new()
	if json.parse(text) != OK:
		return {"__error": "JSON inválido (%s)" % json.get_error_message()}
	var data = json.get_data()
	if typeof(data) != TYPE_DICTIONARY:
		return {"__error": "el JSON no es un diccionario"}
	return data


func _load_from_file() -> void:
	raw_label.text = "Archivo: (no existe)"
	var data := _read_save_file()
	if data.is_empty():
		level_spin.value = 1
		coin_spin.value = 1
		damage_spin.value = int(GameManager.playerDamage)
		status_label.text = "No hay guardado. Los valores son los de una partida nueva."
	elif data.has("__error"):
		status_label.text = "El guardado está roto: %s" % data["__error"]
	else:
		level_spin.value = int(data.get("levelNumber", 1))
		coin_spin.value = int(data.get("plasticoin", 1))
		damage_spin.value = int(data.get("playerDamage", GameManager.playerDamage))
		status_label.text = "Guardado cargado desde el archivo."
	_update_hints()


# Pasa los valores de la pantalla a GameManager (en memoria, todavía sin guardar)
func _apply_to_game_manager() -> void:
	GameManager.levelNumber = int(level_spin.value)
	GameManager.plasticoin = int(coin_spin.value)
	GameManager.playerDamage = int(damage_spin.value)


func _update_hints() -> void:
	var level := int(level_spin.value)
	if level >= 1 and level <= LEVELS.size():
		level_hint.text = "Al salir del descanso va a: %s" % LEVELS[level - 1].get_file()
	else:
		level_hint.text = "Valor fuera de 1-%d: el juego cae en edificio.tscn" % LEVELS.size()

	var rest_path := REST_PATH % int(coin_spin.value)
	if ResourceLoader.exists(rest_path):
		coin_hint.text = "Sala de descanso: %s" % rest_path.get_file()
	else:
		coin_hint.text = "No existe %s: el juego usa descanso1" % rest_path.get_file()


# ---------------------------------------------------------------- Botones

func _on_save_pressed() -> void:
	_apply_to_game_manager()
	GameManager.save_game()
	_load_from_file()
	status_label.text = "Guardado escrito."


func _on_delete_pressed() -> void:
	# Doble clic para confirmar (se desarma solo a los 3 segundos)
	if not delete_armed:
		delete_armed = true
		delete_button.text = "¿Seguro? Clic otra vez"
		await get_tree().create_timer(3.0).timeout
		delete_armed = false
		delete_button.text = "Borrar guardado"
		return
	delete_armed = false
	delete_button.text = "Borrar guardado"
	var error := DirAccess.remove_absolute(ProjectSettings.globalize_path(GameManager.SAVE_FILE_PATH))
	_load_from_file()
	if error == OK:
		status_label.text = "Guardado borrado. Ahora el menú no mostrará CONTINUE."
	else:
		status_label.text = "No se pudo borrar (código %d)." % error


func _on_open_folder_pressed() -> void:
	OS.shell_open(ProjectSettings.globalize_path("user://"))


func _on_go_pressed() -> void:
	_apply_to_game_manager()
	var target_id := target_option.get_selected_id()
	var scene_path := ""
	match target_id:
		TARGET_REST:
			scene_path = GameManager.get_descanso_scene()
		TARGET_TUTORIAL:
			scene_path = TUTORIAL_SCENE
		TARGET_MENU:
			scene_path = MENU_SCENE
		_:
			# Nivel directo: levelNumber = ese nivel, como si viniéramos del descanso.
			# Al terminarlo el juego lo sube en 1 y guarda igual que siempre.
			GameManager.levelNumber = target_id
			scene_path = LEVELS[target_id - 1]
	if save_before_go.button_pressed:
		GameManager.save_game()
	if not ResourceLoader.exists(scene_path):
		status_label.text = "No existe la escena %s" % scene_path
		return
	get_tree().change_scene_to_file(scene_path)
