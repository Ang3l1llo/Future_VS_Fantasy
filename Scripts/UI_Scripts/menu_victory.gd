extends Control


func _on_bt_continue_pressed():
	var current_scene = Global.current_level
	var next_scene = ""
	
	if current_scene == "res://Scenes/Levels/MeadowLands.tscn":
		next_scene = "res://Scenes/Levels/MisteryWoods.tscn"
	elif current_scene == "res://Scenes/Levels/MisteryWoods.tscn":
		next_scene = "res://Scenes/Levels/FinalZone.tscn"
	else:
		pass
		#POR HACER, MOSTRAR VICTORIA FINAL

	get_tree().change_scene_to_file(next_scene)

func _on_bt_exit_pressed():
	get_tree().change_scene_to_file("res://Scenes/UI/menu_principal.tscn")
