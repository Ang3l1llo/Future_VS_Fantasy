extends Area2D

func _ready():
	if $Pivot.has_node("Left"):
		$Pivot/Left.visible = false

func _on_body_entered(body):
	if body.name == "Player":
		print("Recogiendo arma...")

		call_deferred("_equip_weapon", body)

func _equip_weapon(body):
	if body.weapon_reference:
		body.weapon_reference.queue_free()  # Elimina el arma anterior
		
	# Mostrar las manos que estaban ocultas
	if $Pivot.has_node("Left"):
		$Pivot/Left.visible = true

	self.name = "ArmaEquipada"
	$Pivot.position = Vector2(5, 0)


	# Mover el arma al jugador
	get_parent().remove_child(self)
	body.add_child(self)
	self.position = body.get_node("WeaponSlot").position

	# Guardar la referencia
	body.weapon_reference = self

#Función para disparar
func shoot():
	const BULLET = preload("res://Scenes/Weapons/BULLETS/bullet_pistol.tscn")
	var new_bullet = BULLET.instantiate()

	# Base de disparo
	var shooting_position = $Pivot/ShootingPoint.global_position

	# Para comprobar si el arma esta invertida
	var is_flipped = scale.y == -1

	# offset solo cuando el arma esté invertida
	var offset = Vector2.ZERO
	if is_flipped:
		offset = Vector2(0, -5)  # Básicamente para que al rotar el arma, el pryectil salga desde la posición correcta

	offset = offset.rotated(rotation)

	# Posición final con ajuste solo si está invertida
	new_bullet.global_position = shooting_position + offset

	new_bullet.rotation = rotation

	get_tree().current_scene.add_child(new_bullet)
