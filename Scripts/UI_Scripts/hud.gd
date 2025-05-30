extends Control 

@export var player_path: NodePath
@export var life_bar: TextureProgressBar  # Barra de vida
@export var timer_label: Label  # Etiqueta para el temporizador
@export var game_duration: float = 25  # 10 mins
@onready var score_label = $ScoreLabel #Puntuación

var timer: float = game_duration
var is_game_over: bool = false

var player: CharacterBody2D

func _ready():
	player = get_node(player_path) 

	life_bar.max_value = player.max_health
	life_bar.value = player.current_health
	
	# Establecer el temporizador inicial
	update_timer_label()

func _process(delta):
	if is_game_over:
		return

	# Actualiza la vida del jugador 
	life_bar.value = player.current_health
	var percent = clamp(round((float(player.current_health) / float(player.max_health)) * 100), 0, 100)
	$"HealthBar/PercentageLabel".text = str(percent) + "%"
	
	#Actualiza puntuación
	score_label.text = "%s | Score: %d" % [Global.player_name, Global.score]
	
	# Reduce el tiempo del temporizador
	if timer > 0:
		timer -= delta
		update_timer_label()
	else:
		# Cuando el tiempo se acaba, pasaríamos al menú de victoria para ir al siguiente nivel
		is_game_over = true
		Global.current_level = get_tree().current_scene.scene_file_path
		get_tree().change_scene_to_file("res://Scenes/UI/menu_victory.tscn")

func update_timer_label():
	# Convertir el tiempo restante en minutos y segundos
	var minutes = int(float(timer) / 60) # Sino daba error por divisiones enteras
	var seconds = int(timer) % 60
	timer_label.text = "%02d:%02d" % [minutes, seconds]
	
func get_elapsed_time() -> float:
	return game_duration - timer
