extends Control

@onready var lore_label = $Texto
@onready var press_any_key = $PressAnyKey
@onready var timer = $Timer
@onready var audio_player = $AudioStreamPlayer
var blink_tween = null

var text := """
Año 2030, el mundo se va a la mierda...


Los políticos han abandonado a la población por sus propios intereses y beneficios.

Las personas de mayor estatus social y económico huyen a sus refugios nucleares y sus palacios de cristal.

Las guerras por los recursos y por simplemente mostrar poder han acabado con casi toda la población.

Los que todavía viven solo ven miseria, contaminación y muerte.

Pero un grupo de rebeldes quieren cambiar las cosas.

Con la ayuda de un equipo de científicos, programadores e ingenieros se crea el proyecto KRONOS.

Una persona sometida al entrenamiento más extremo y con sed de venganza por la muerte de toda su familia,
va a ser enviada al pasado para eliminar a los causantes de todo esto.

El viaje es solo de ida. Pero eso no le importa a nuestro héroe,
solo quiere la muerte de aquellos que le arrebataron todo.

Tú eres la última esperanza.


Prepárate para una batalla sin retorno...
"""

var current_index = 0
var displayed_text = ""
var lore_finished = false

func _ready():
	press_any_key.visible = false  
	audio_player.play()
	timer.start()

func _on_TypeTimer_timeout():
	if current_index < text.length():
		displayed_text += text[current_index]
		lore_label.text = displayed_text
		current_index += 1
	else:
		timer.stop()
		lore_finished = true
		press_any_key.visible = true  
		_start_blinking()

func _unhandled_input(event):
	if lore_finished and event is InputEventKey and event.pressed:
		get_tree().change_scene_to_file("res://Scenes/Levels/MeadowLands.tscn")

#Para el efectito visual del parpadeo
func _start_blinking():
	if blink_tween != null:
		return
	blink_tween = create_tween()
	blink_tween.set_loops()
	blink_tween.tween_property(press_any_key, "modulate:a", 0.0, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	blink_tween.tween_property(press_any_key, "modulate:a", 1.0, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
