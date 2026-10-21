extends Node2D

var Segundos : int
var playerDamage = 10
var currentLevel : String
var levelNumber : int = 0
var plasticoin : int = 0 
var goal: bool = false
var descanso: bool = false
var extra_time : int = 0
var music_on : bool = true
var transicion_bg : int = 0
var ninja_boss : int = 0

const SAVE_FILE_PATH = "user://save_game.save"

func takeDamage(damage):
	Segundos -= damage
	if Segundos <= 0:
		Segundos = 0
		
func reachedGoal(win):
	goal = win

# Función para guardar los datos
func save_game() -> void:
	var save_data = {
		"playerDamage": playerDamage,
		"levelNumber": levelNumber,
		"plasticoin": plasticoin
	}
	
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file:
		# Convertimos el diccionario a formato JSON y lo guardamos
		var json_string = JSON.stringify(save_data)
		file.store_string(json_string)
		print("¡Juego guardado exitosamente!")
	else:
		print("Error al intentar guardar el archivo.")

# Función para cargar los datos (retorna un diccionario con los valores o vacío si no existe)
func load_game() -> Dictionary:
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		print("No se encontró ningún archivo de guardado.")
		return {}
	
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		var json = JSON.new()
		var error = json.parse(json_string)
		
		if error == OK:
			var save_data = json.get_data()
			print("¡Juego cargado exitosamente!")
			return save_data
		else:
			print("Error al parsear el archivo JSON: ", json.get_error_message())
			
	return {}
	
	# Retorna true si el archivo de guardado ya existe, false si no.
func save_file_exists() -> bool:
	return FileAccess.file_exists(SAVE_FILE_PATH)
