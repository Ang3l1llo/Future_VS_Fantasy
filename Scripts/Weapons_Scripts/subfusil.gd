extends Area2D

var damage = 20
var fire_rate := 0.1
var cooldown_timer := 0.0

func _physics_process(delta):
	if cooldown_timer > 0.0:
		cooldown_timer -= delta
		
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
	
	
#Función para disparar
func shoot():
	if cooldown_timer > 0.0:
		return
		
	cooldown_timer = fire_rate
	
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
	
	new_bullet.damage = damage

	get_tree().current_scene.add_child(new_bullet)
	
	new_bullet.activate_shooting()
