extends Control

func _on_bt_retry_pressed():
	get_tree().change_scene_to_file("res://Scenes/Levels/MeadowLands.tscn")


func _on_bt_quit_pressed():
	get_tree().change_scene_to_file("res://Scenes/UI/menu_principal.tscn")
