extends Area2D

func _ready():
	if $Pivot.has_node("Right"):
		$Pivot/Right.visible = false
	if $Pivot.has_node("Left"):
		$Pivot/Left.visible = false

func _on_body_entered(body):
	if body.name == "Player":
		print("Recogiendo arma...")

		call_deferred("_equip_weapon", body)

func _equip_weapon(body):
	# Mostrar las manos
	if $Pivot.has_node("Right"):
		$Pivot/Right.visible = true
	if $Pivot.has_node("Left"):
		$Pivot/Left.visible = true

	self.name = "ArmaEquipada"
	$Pivot.position = Vector2(50, 0)


	# Mover el arma al jugador
	get_parent().remove_child(self)
	body.add_child(self)
	self.position = Vector2(0, 0)

	# Guardar la referencia
	body.weapon_reference = self
