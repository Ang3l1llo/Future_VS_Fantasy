extends Node
#Esto es un singleton que usaremos para determinadas cosas globales
var current_level: String = ""

var equip_sound = preload("res://Music/Effects_music/Equip_weapon.wav")
var audio_player: AudioStreamPlayer

func _ready():
	audio_player = AudioStreamPlayer.new()
	audio_player.stream = equip_sound
	add_child(audio_player)
	
func play_equip_sound():
	if audio_player:
		audio_player.play()
