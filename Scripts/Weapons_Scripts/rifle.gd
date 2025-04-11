extends Area2D

func _ready():
	if $Pivot.has_node("Left"):
		$Pivot/Left.visible = false
	if $Pivot.has_node("Right"):
		$Pivot/Right.visible = false

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
	if $Pivot.has_node("Right"):
		$Pivot/Right.visible = true

	self.name = "ArmaEquipada"
	$Pivot.position = Vector2(0, 0)


	# Mover el arma al jugador
	get_parent().remove_child(self)
	body.add_child(self)
	self.position = body.get_node("WeaponSlot").position

	# Guardar la referencia
	body.weapon_reference = self
