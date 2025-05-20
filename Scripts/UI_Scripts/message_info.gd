extends Control

@onready var texto_label = $TextureRect/Message
@onready var timer = $Timer

@export var nombre_mapa: String = ""

var mensajes_por_mapa = {
	"MeadowLands": """[TRANSMISIÓN INICIADA]

Bienvenido, Operativo KRONOS.
Ha habido complicaciones con la transportación..

Parece que has acabado en otro universo..

Localización actual: Lo llaman MeadowLands - Año 856.
Objetivos prioritarios: SOBREVIVIR.
Serás transportado a otro lugar. 

Prepárate, coge tu arma..
Enemigos detectados en las cercanías…
""",
	"MisteryWoods": """[TRANSMISIÓN]

Están surgiendo muchas dificultades
para traerte de vuelta..

Te hemos llevado a otro lugar más seguro,
aquí parece no haber vida.

Localización actual: MisteryWoods? - Año ???
Objetivo: Esperar para otro transporte.

Mierda..parece que no estás solo..
Algo se acerca algo hacia ti..
""",
	"FinalZone": """[TRANS..MI/¿..SIÓN]

La última batalla... prepárate para lo peor.
"""
}

var mensaje := ""
var current_index = 0
var displayed_text = ""
var finished = false

func _ready():
	mensaje = mensajes_por_mapa.get(nombre_mapa, "Zona desconocida")
	texto_label.text = ""
	timer.start()

func _on_Timer_timeout():
	if current_index < mensaje.length():
		displayed_text += mensaje[current_index]
		texto_label.text = displayed_text
		current_index += 1
	else:
		timer.stop()
		finished = true
		await get_tree().create_timer(4).timeout
		queue_free()
