extends Control

@onready var weapon_bt = $Button_weapon
@onready var life_bt = $Button_life
@onready var speed_bt = $Button_speed

var player_ref

func _ready():
	visible = false  # Ocultar al inicio

func show_menu(player):
	player_ref = player
	visible = true
	

func  _on_upgrade_weapon():
	weapon_bt.play()
	if player_ref.has_max_weapon():
		show_message("¡Ya tienes el mejor arma!")
		return
	
	player_ref.upgrade_weapon()
	close_menu()

func _on_increase_health():
	life_bt.play()
	player_ref.max_health += 100
	player_ref.current_health = player_ref.max_health
	close_menu()

func _on_increase_speed():
	speed_bt.play()
	player_ref.movement_speed += 20.0
	close_menu()

func show_message(text):
	var label = $MessageLabel
	label.text = text
	label.visible = true
	await get_tree().create_timer(2.0).timeout  
	label.visible = false

func close_menu():
	visible = false
	get_tree().paused = false
