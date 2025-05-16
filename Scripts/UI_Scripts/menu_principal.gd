extends Control

@onready var onClick = $ButtonClickPlay
@onready var timer = $ChangeSceneTimer
@onready var start_button = $Bt_start
@onready var animation_player = $AnimationPlayer
@onready var music = $Music

func _ready():
	animation_player.play("fade_in")
	
func _on_bt_start_pressed():
	start_button.disabled = true #Estom lo hago para evitar spams
	music.stop()
	onClick.play()
	timer.start()

func _on_bt_settings_pressed():
	pass

func _on_bt_quit_pressed():
	get_tree().quit()

func _on_change_scene_timer_timeout():
	get_tree().change_scene_to_file("res://Scenes/Levels/MeadowLands.tscn")
