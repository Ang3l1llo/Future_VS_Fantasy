extends Control

@onready var start_button_music = $ButtonMusicPlay
@onready var tops_button_music = $ButtonMusicTop5
@onready var load_button_music = $ButtonMusicLoadGame
@onready var timer = $ChangeSceneTimer
@onready var start_button = $Bt_start
@onready var tops_button = $Bt_tops
@onready var load_button = $Bt_load
@onready var animation_player = $AnimationPlayer
@onready var music = $Music

func _ready():
	animation_player.play("fade_in")
	if !FileAccess.file_exists("user://savegame.json"):
		load_button.disabled = true
	
	
func _on_bt_start_pressed():
	start_button.disabled = true #Estom lo hago para evitar spams
	Global.reset() #Borra datos al iniciar nueva partida
	music.stop()
	start_button_music.play()
	timer.start()


func _on_best_players_button_pressed():
	tops_button.disabled = true
	tops_button_music.play()
	await tops_button_music.finished
	Global.fetch_top5(self)  
	get_tree().change_scene_to_file("res://Scenes/UI/top_5.tscn")


func _on_bt_quit_pressed():
	get_tree().quit()


func _on_change_scene_timer_timeout():
	get_tree().change_scene_to_file("res://Scenes/UI/input_player_name.tscn")
	
	
#Respuesta para verificar que llegan datos
func _on_top5_received(_result, response_code, _headers, body):
	if response_code == 200:
		Global.top5_players = JSON.parse_string(body.get_string_from_utf8())
		get_tree().change_scene_to_file("res://Scenes/UI/top5_players.tscn")
	else:
		print("Error al recibir el top 5:", response_code)


func _on_bt_load_pressed():
	load_button.disabled = true
	load_button_music.play()
	var next_level = Global.get_next_unlocked_level()
	Global.current_level = next_level  # Para que se actualice correctamente el nivel actual
	get_tree().change_scene_to_file(next_level)
