extends Control

var player_ref

func _ready():
	visible = false  # Ocultar al inicio

func show_menu(player):
	player_ref = player
	visible = true

func  _on_upgrade_weapon():
		player_ref.upgrade_weapon()
		close_menu()

func _on_increase_health():
	player_ref.max_health += 100
	player_ref.current_health = player_ref.max_health
	close_menu()

func _on_increase_speed():
	player_ref.movement_speed += 20.0
	close_menu()

func close_menu():
	visible = false
	get_tree().paused = false
