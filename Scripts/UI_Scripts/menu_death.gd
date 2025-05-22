extends Control

@onready var death_button = $Button_death
@onready var restart_button = $Bt_retry
@onready var exit_button = $Button_exit
@onready var quit_button = $Bt_quit

func _on_bt_retry_pressed():
	restart_button.disabled = true
	quit_button.disabled = true
	death_button.play()
	await death_button.finished
	Global.score = Global.score_at_level_start
	get_tree().change_scene_to_file(Global.current_level)

func _on_bt_quit_pressed():
	quit_button.disabled = true
	restart_button.disabled = true
	exit_button.play()
	await exit_button.finished
	get_tree().change_scene_to_file("res://Scenes/UI/menu_principal.tscn")
