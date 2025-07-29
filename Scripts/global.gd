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
var equip_sound = preload("res://Music/Effects/Equip_weapon.wav")
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
	score_at_level_start = 0
	
	# Resetea progreso
	progress = {
		"MeadowLands": false,
		"MisteryWoods": false,
		"FinalZone": false
	}
	delete_save_file()
	
#Guarda puntuación localmente
func add_points_local(points: int):
	score += points
	
# Llamada a la API para crear jugador
func create_player(nombre: String):
	player_name = nombre  # Guardamos inmediatamente
	var url = "https://api-psp-1nuc.onrender.com/api/Player"
	var headers = ["Content-Type: application/json"]
	var body = JSON.stringify({ "nombre": nombre, "puntuacion": 0 })

	var request = HTTPRequest.new()
	add_child(request)

	request.request_completed.connect(_on_create_player_completed.bind(request))  # usamos bind

	var err = request.request(url, headers, HTTPClient.METHOD_POST, body)
	if err != OK:
		push_error("Error al crear jugador: %s" % err)

# Manejador directo para crear jugador
func _on_create_player_completed(_result, response_code, _headers, body, request):
	if response_code == 201:
		var parsed = JSON.parse_string(body.get_string_from_utf8())
		if parsed is Dictionary and parsed.has("id"):
			player_id = parsed["id"]
			print("ID del jugador recibido:", player_id)
			# Guardar en disco si ya se ha comenzado la partida
			save_progress("")  # "" evita marcar niveles como completados
		else:
			print("Respuesta sin ID válida.")
	else:
		print("Error al crear el jugador en la API. Código:", response_code)

	request.queue_free()



# Llamada a la API para sumar puntos
func add_points():
	if player_id == "":
		print("ID del jugador no definido aún")
		return
		
	if score <= score_at_level_start:
		print("No hay puntuación nueva que enviar.")
		return

	#Ese /%s es una forma de formatear el string en GDScript
	var url = "https://api-psp-1nuc.onrender.com/api/Player/%s/addpoints" % player_id
	var headers = ["Content-Type: application/json"]
	var body = str(score)

	var request = HTTPRequest.new()
	add_child(request)
	
	request.request_completed.connect(func(_result, response_code, _headers, _body):
		if response_code == 200:
			print("Puntuación enviada con éxito")
		else:
			print("Falló el envío de puntuación. Código:", response_code)
		request.queue_free()
	)

	var err = request.request(url, headers, HTTPClient.METHOD_PUT, body)
	if err != OK:
		print("Error al enviar puntuación:", err)
	
	
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
	
	# Cargar datos actuales guardados para no perderlos
	var data = {
		"progress": {
			"MeadowLands": false,
			"MisteryWoods": false,
			"FinalZone": false
		},
		"player_id": Global.player_id,
		"player_name": Global.player_name,
		"score": Global.score
	}
	
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		var content = file.get_as_text()
		var parsed = JSON.parse_string(content)
		if typeof(parsed) == TYPE_DICTIONARY:
			data = parsed
		file.close()
	
	# Actualizar progreso si nivel válido
	if level_name != "":
		var clean_name = level_name.get_file().get_basename()
		data["progress"][clean_name] = true
	
	# Actualizar nombre y score actuales (por si cambiaron)
	data["player_id"] = Global.player_id
	data["player_name"] = Global.player_name
	data["score"] = Global.score
	
	# Guardar datos actualizados
	var fileNewData = FileAccess.open(save_path, FileAccess.WRITE)
	fileNewData.store_string(JSON.stringify(data))
	fileNewData.close()


# Funciñon para cargar partida
func load_progress():
	var save_path = "user://savegame.json"
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		var content = file.get_as_text()
		var parsed = JSON.parse_string(content)
		if typeof(parsed) == TYPE_DICTIONARY:
			if parsed.has("progress"):
				progress = parsed["progress"]
			if parsed.has("player_id"):  
				Global.player_id = parsed["player_id"]
			if parsed.has("player_name"):
				Global.player_name = parsed["player_name"]
			if parsed.has("score"):
				Global.score = parsed["score"]
		file.close()


#Borrar datos
func delete_save_file():
	var dir = DirAccess.open("user://")
	if dir.file_exists("savegame.json"):
		var err = dir.remove("savegame.json")
		if err != OK:
			print("Error al borrar el archivo de guardado:", err)


#Para cargar el nivel correspondient
func get_next_unlocked_level() -> String:
	load_progress()  
	print("Progreso cargado:", progress)

	if !progress.get("MeadowLands", false):
		return "res://Scenes/Levels/MeadowLands.tscn"
	elif !progress.get("MisteryWoods", false):
		return "res://Scenes/Levels/MisteryWoods.tscn"
	elif !progress.get("FinalZone", false):
		return "res://Scenes/Levels/FinalZone.tscn"
	else:
		return "res://Scenes/UI/credit_scene.tscn"
