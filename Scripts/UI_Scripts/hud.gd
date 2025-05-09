extends Control

@export var player_path: NodePath
@export var life_bar: TextureProgressBar  # Barra de vida
@export var timer_label: Label  # Etiqueta para el temporizador
@export var game_duration: float = 600.0  # 10 mins

var timer: float = game_duration
var is_game_over: bool = false

var player = CharacterBody2D

func _ready():
	player = get_node(player_path)
	life_bar.max_value = player.get("max_health")  
	life_bar.value = player.get("current_health")  
	# Establecer el temporizador inicial
	update_timer_label()

func _process(delta):
	if is_game_over:
		return
		
	# Actualiza la vida del jugador 
	life_bar.value = player.get("current_health")
	
	# Reduce el tiempo del temporizador
	if timer > 0:
		timer -= delta
		update_timer_label()
	else:
		# Cuando el tiempo se acaba, pasaríamos al segundo nivel
		is_game_over = true
		# POR HACER
		# EJEMPLO: get_tree().change_scene("res://level2.tscn")

func update_timer_label():
	# Convertir el tiempo restante en minutos y segundos
	var minutes = int(timer) / 60
	var seconds = int(timer) % 60
	timer_label.text = "%02d:%02d" % [minutes, seconds]
