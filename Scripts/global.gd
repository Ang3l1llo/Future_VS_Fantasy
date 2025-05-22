extends Node
# SINGLETON para gestionar variables y funciones globales

#Para asignar el nivel al menú victoria y no pierda referencias
var current_level: String = ""

# Variables para la puntuación y la API
var player_name: String = ""
var player_id: String = ""
var score: int = 0
var score_at_level_start: int = 0
var top5_players: Array = []


#Varibales para guardar partida
var progress = {
	"MeadowLands": false,
	"MisteryWoods": false,
	"FinalZone": false
}

# Sonido de equipar
var equip_sound = preload("res://Music/Effects_music/Equip_weapon.wav")
var audio_player: AudioStreamPlayer


func _ready():
	audio_player = AudioStreamPlayer.new()
	audio_player.stream = equip_sound
	add_child(audio_player)

#Sonidito de equipar arma
func play_equip_sound():
	if audio_player:
		audio_player.play()


func reset():
	player_name = ""
	player_id = ""
	score = 0


# Llamada a la API para crear jugador
func create_player(nombre: String, callback_node: Node):
	player_name = nombre
	var url = "https://api-psp-1nuc.onrender.com/api/Player"
	var headers = ["Content-Type: application/json"]
	var body = JSON.stringify({ "nombre": nombre, "puntuacion": 0 })

	var request = HTTPRequest.new()
	add_child(request)
	request.request_completed.connect(callback_node._on_create_player_completed)
	var err = request.request(url, headers, HTTPClient.METHOD_POST, body)
	if err != OK:
		push_error("Error al crear jugador: %s" % err)


# Llamada a la API para sumar puntos
func add_points(points: int):
	if player_id == "":
		print("ID del jugador no definido aún")
		return
	score += points

	#Ese /%s es una forma de formatear el string en GDScript
	var url = "https://api-psp-1nuc.onrender.com/api/Player/%s/addpoints" % player_id
	var headers = ["Content-Type: application/json"]
	var body = str(points)

	var request = HTTPRequest.new()
	add_child(request)
	request.request(url, headers, HTTPClient.METHOD_PUT, body)
	
	
# Llamada a la API para obtener el top 5 de jugadores
func fetch_top5(callback_node: Node):
	var url = "https://api-psp-1nuc.onrender.com/api/Player/top5"
	var request = HTTPRequest.new()
	add_child(request)

	request.request_completed.connect(callback_node._on_top5_received)
	var err = request.request(url)
	if err != OK:
		push_error("Error al pedir el top 5: %s" % err)


#Para guardar el progrso
func save_progress(level_name: String):
	var save_path = "user://savegame.json"

	# Cargar datos existentes si los hubiera
	if FileAccess.file_exists(save_path):
		var checkfile = FileAccess.open(save_path, FileAccess.READ)
		var content = checkfile.get_as_text()
		var parsed = JSON.parse_string(content)

		if typeof(parsed) == TYPE_DICTIONARY:
			progress = parsed
		else:
			# Si el contenido es inválido, reiniciar
			progress = {
				"MeadowLands": false,
				"MisteryWoods": false,
				"FinalZone": false
			}
		checkfile.close()
	
	# Marcar el nivel como completado
	progress[level_name] = true
	
	# Guarda el nuevo progreso
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(progress))
	file.close()


# Funciñon para cargar partida
func load_progress():
	var save_path = "user://savegame.json"
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		var content = file.get_as_text()
		var parsed = JSON.parse_string(content)
	
		if typeof(parsed) == TYPE_DICTIONARY:
			progress = parsed
		
		file.close()


#Para cargar el nivel correspondient
func get_next_unlocked_level() -> String:
	load_progress()  

	if !progress.get("MeadowLands", false):
		return "res://Scenes/Levels/MeadowLands.tscn"
	elif !progress.get("MisteryWoods", false):
		return "res://Scenes/Levels/MisteryWoods.tscn"
	elif !progress.get("FinalZone", false):
		return "res://Scenes/Levels/FinalZone.tscn"
	else:
		return ""  # FALTARÍA PAMNTALLITA FINAL VICTORIA
