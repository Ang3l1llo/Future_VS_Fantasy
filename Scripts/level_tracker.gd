extends Node2D


func _ready():
	Global.current_level = get_scene_file_path()
