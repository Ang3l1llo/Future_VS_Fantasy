extends Area2D

var damage = 15
var fire_rate := 0.5
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
	
	const BULLET = preload("res://Scenes/Weapons/BULLETS/bullet_shotgun.tscn")
	var shooting_position = $Pivot/ShootingPoint.global_position
	var is_flipped = scale.y == -1

	# Ajuste de posición si el arma está volteada
	var base_offset = Vector2(0, -1) if is_flipped else Vector2.ZERO
	base_offset = base_offset.rotated(rotation)

	# Parámetros de la escopeta
	var num_pellets = 5  # Número de balas por disparo
	var spread_angle = deg_to_rad(20)  # Ángulo total de dispersión 

	for i in num_pellets:
		var pellet = BULLET.instantiate()

		# Ángulo individual para cada bala 
		var angle_offset = spread_angle * (float(i) / (num_pellets - 1) - 0.5)
		var final_rotation = rotation + angle_offset

		# Posición de cada proyectil
		pellet.global_position = shooting_position + base_offset
		pellet.rotation = final_rotation
		
		pellet.damage = damage

		get_tree().current_scene.add_child(pellet)
		
		pellet.activate_shooting()
