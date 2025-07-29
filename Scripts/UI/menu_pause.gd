extends Control

# Variable para saber si el juego está pausado
var is_paused = false

var is_dead = false

@onready var pause_button = $Pause
@onready var restart_exit_button = $Buttons

func _ready():
	# El menú de pausa empieza oculto
	visible = false

func _input(event: InputEvent):
	if not is_dead and event.is_action_pressed("pause"):		
		# Ahora se cambia el estado y estaría pausado
		is_paused = !is_paused
		get_tree().paused = is_paused
		
		# Se hace visible el menú
		visible = is_paused
		
		pause_button.play()
		await pause_button.finished

# Para reiniciar
func _on_bt_restart_pressed():
	restart_exit_button.play()
	await restart_exit_button.finished
	
	#Evitar que suene la música de fondo al pulsar 
	var music_controller = get_tree().current_scene.get_node_or_null("MusicController")
	if music_controller:
		music_controller.stop_all_music()
		
	Global.score = Global.score_at_level_start
 
	get_tree().paused = false
	get_tree().reload_current_scene()

# Para salir al menú principal
func _on_bt_exit_pressed():
	restart_exit_button.play()
	await restart_exit_button.finished
	
	var music_controller = get_tree().current_scene.get_node_or_null("MusicController")
	if music_controller:
		music_controller.stop_all_music()
		
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/UI/menu_principal.tscn")
