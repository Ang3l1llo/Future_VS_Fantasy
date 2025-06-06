extends Node2D


func _ready():
	Global.current_level = get_tree().current_scene.scene_file_path
