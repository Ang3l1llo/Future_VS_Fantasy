extends Control

# Variable para saber si el juego está pausado
var is_paused = false

var is_dead = false

func _ready():
	# El menú de pausa empieza oculto
	visible = false

func _input(event: InputEvent):
	if not is_dead and event.is_action_pressed("pause"):
		print("pausado")
		
		# Ahora se cambia el estado y estaría pausado
		is_paused = !is_paused
		get_tree().paused = is_paused
		
		# Se hace visible el menú
		visible = is_paused

# Para reiniciar
func _on_bt_restart_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

# Para salir al menú principal
func _on_bt_exit_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/UI/menu_principal.tscn")
