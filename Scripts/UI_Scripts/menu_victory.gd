extends Control

@onready var button_continue = $Button_continue
@onready var button_exit = $Button_exit
@onready var music = $Music


func _on_bt_continue_pressed():
	await music.finished
	button_continue.play()
	await button_continue.finished
	
	#Guardar progreso
	var level_name = Global.current_level.get_file().get_basename() #Para no quedarnos con la ruta entera, solo nombre del mapa
	Global.save_progress(level_name)
	
	#Tener constancia del nivel actual
	var current_scene = Global.current_level
	var next_scene = ""
	
	if current_scene == "res://Scenes/Levels/MeadowLands.tscn":
		next_scene = "res://Scenes/Levels/MisteryWoods.tscn"
	elif current_scene == "res://Scenes/Levels/MisteryWoods.tscn":
		next_scene = "res://Scenes/Levels/FinalZone.tscn"
	else:
		pass
		#POR HACER, MOSTRAR VICTORIA FINAL

	Global.score_at_level_start = Global.score
	get_tree().change_scene_to_file(next_scene)
	

func _on_bt_exit_pressed():
	await music.finished
	button_exit.play()
	await button_exit.finished
	get_tree().change_scene_to_file("res://Scenes/UI/menu_principal.tscn")
