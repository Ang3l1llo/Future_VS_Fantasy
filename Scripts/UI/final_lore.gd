extends Control


@onready var lore_label = $Texto
@onready var timer = $Timer
@onready var audio_player = $AudioStreamPlayer
@onready var wait_timer = $WaitTimer

var text := """
¡¡¡ENHORABUENA!!! ¡¡Has escapado!! ¡Es increíble que hayas sobrevivido!

Has conseguido volver a casa..aunque...

Has estado matando seres de otros universos y no solucionaste realmente el problema..

El mundo sigue siendo una mierda...
"""

var current_index = 0
var displayed_text = ""

func _ready():
	audio_player.play()
	timer.start()


func _on_timer_timeout():
	if current_index < text.length():
		displayed_text += text[current_index]
		lore_label.text = displayed_text
		current_index += 1
	else:
		timer.stop()
		wait_timer.start()	


func _on_wait_timer_timeout():
	get_tree().change_scene_to_file("res://Scenes/UI/credit_scene.tscn")
