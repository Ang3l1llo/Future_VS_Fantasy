extends Control

@onready var back_button = $Bt_back
@onready var back_button_audio = $Back_button_audio
@onready var loading_bar = $AnimatedSprite2D
@onready var label_nodes := [
	$Player1Label,
	$Player2Label,
	$Player3Label,
	$Player4Label,
	$Player5Label
]

func _ready():
	loading_bar.modulate = Color(0, 0.5, 1)
	loading_bar.visible = true
	loading_bar.play()
	load_top5()
	
#Carga el top5 de jugadores a la API
func load_top5():
	var url = "https://api-psp-1nuc.onrender.com/api/Player/top5"
	var request = HTTPRequest.new()
	add_child(request)
	request.request_completed.connect(_on_top5_response)
	request.request(url)

#Para asegurar que funcione
func _on_top5_response(_result, response_code, _headers, body):
	loading_bar.stop()
	loading_bar.visible = false
	
	if response_code == 200:
		var players = JSON.parse_string(body.get_string_from_utf8())
		Global.top5_players = players
		show_players()
	else:
		print("Error al obtener top5:", response_code)
		
#Muestra los 5 mejores jugadores en los labels correspondientes
func show_players():
	for i in range(5):
		if i < Global.top5_players.size():
			var player = Global.top5_players[i]
			label_nodes[i].text = "%s - %d pts" % [player["nombre"], player["puntuacion"]]
		else:
			label_nodes[i].text = "---"

func _on_bt_back_pressed():
	back_button_audio.play()
	await back_button_audio.finished
	get_tree().change_scene_to_file("res://Scenes/UI/menu_principal.tscn")
	
