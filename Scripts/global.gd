extends Node
# Singleton para gestionar variables y funciones globales

#Para asignar el nivel al menú victoria
var current_level: String = ""

# Variables para la puntuación y la API
var player_name: String = ""
var player_id: String = ""
var score: int = 0
var top5_players: Array = []

# Sonido de equipar
var equip_sound = preload("res://Music/Effects_music/Equip_weapon.wav")
var audio_player: AudioStreamPlayer

func _ready():
	audio_player = AudioStreamPlayer.new()
	audio_player.stream = equip_sound
	add_child(audio_player)

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
