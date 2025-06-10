extends Node

@export var current_map: String = "MeadowLands"
@export var hud_path: NodePath

var hud
var songs: Array = []
var change_times: Array = []
var current_song_index := 0
var time_elapsed := 0.0
var is_waiting := false

var level_music_config = {
	"MeadowLands": {
		"songs": [
			"res://Music/Battle/MeadowLands/Musica_mapa1_early.mp3",
			"res://Music/Battle/MeadowLands/Musica_mapa1_midgame.mp3",
			"res://Music/Battle/MeadowLands/Musica_mapa1_lategame.mp3"
		]
	},
	"MisteryWoods": {
		"songs": [
			"res://Music/Battle/MisteryWoods/Musica_mapa2_early.mp3",
			"res://Music/Battle/MisteryWoods/Musica_mapa2_midgame.mp3",
			"res://Music/Battle/MisteryWoods/Musica_mapa2_lategame.mp3"
		],
		"custom_change_times": [194.0]
	},
	"FinalZone": {
		"songs": [
			"res://Music/Battle/FinalZone/Musica_mapa3_early.mp3",
			"res://Music/Battle/FinalZone/Musica_mapa3_midgame.mp3",
			"res://Music/Battle/FinalZone/Musica_mapa3_lategame.mp3"
		],
		"custom_change_times": [215.0, 390.0]
	}
}

func _ready():
	hud = get_node(hud_path)

	var config = level_music_config.get(current_map, null)
	if config == null:
		push_error("No hay configuración musical para el mapa: " + current_map)
		return

	for path in config.songs:
		songs.append(load(path))

	if "custom_change_times" in config:
		change_times = config.custom_change_times.duplicate()
		
		# Completar change_times para cubrir todos los cambios de canción
		while change_times.size() < songs.size() - 1:
			var last_time = change_times[-1]
			var next_index = change_times.size()
			var next_duration = songs[next_index].get_length()
			change_times.append(last_time + next_duration)
		
			
	else:
		change_times = []
		var total := 0.0
		for i in range(songs.size() - 1):
			total += songs[i].get_length()
			change_times.append(total)

	play_song(0)

func _process(_delta):
	if hud.is_game_over or is_waiting:
		return

	time_elapsed = hud.get_elapsed_time()

	# Cambiar canción si toca y no es la última y esperar un sec para reproducir la siguiente
	if current_song_index < change_times.size() and time_elapsed >= change_times[current_song_index]:
		pause_before_next_song(1.0)

func play_song(index):
	if index >= songs.size():
		return

	current_song_index = index
	var player = $AudioStreamPlayer
	player.stop()
	player.stream = songs[index]
	player.play()

func pause_before_next_song(seconds):
	is_waiting = true
	var player = $AudioStreamPlayer
	player.stop()
	
	var timer = Timer.new()
	timer.wait_time = seconds
	timer.one_shot = true
	add_child(timer)
	timer.start()
	timer.timeout.connect(_on_pause_timeout)

func _on_pause_timeout():
	is_waiting = false
	play_song(current_song_index + 1)
	
func stop_all_music():
	for child in get_children():
		if child is AudioStreamPlayer:
			child.stop()
