extends Area2D

@export var weapon_texture: Texture  # La textura del arma que se equipará
var is_collected = false  # Para evitar que se recoja más de una vez

func _ready():
	if has_node("Sprite2D"):
		if weapon_texture != null:
			print("Asignando textura al arma...")
			var sprite = $Sprite2D
			sprite.texture = weapon_texture  # Asigna correctamente la textura del arma
		else:
			print("Error: La textura del arma no está asignada correctamente.")
	else:
		print("Error: Sprite2D no encontrado.")

func _on_body_entered(body):
	if body.name == "Player" and not is_collected:
		is_collected = true  # Evita que se recoja más de una vez
		print("Arma recogida, equipando...")
		body.equip_weapon(weapon_texture)  # Pasa la textura del arma al jugador
		
		print("Eliminando el arma del mapa...")
		queue_free()  
