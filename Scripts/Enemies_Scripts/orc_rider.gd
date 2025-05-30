extends CharacterBody2D

@onready var player = get_node("/root/FinalZone/Player")
@onready var sprite = $AnimatedSprite2D
@onready var attack_zone = $AttackZone
@onready var attack_shape1 = attack_zone.get_node("Attack1")
@onready var attack_shape2 = attack_zone.get_node("Attack2")
@onready var attack_shape3 = attack_zone.get_node("Attack3")
@onready var detect_zone = $DetectZone


var can_attack = true
var is_attacking = false
var is_hurt = false
var is_dead = false
var max_health = 600
var current_health = max_health
var damage = 25
var speed = 70
var score_points: int = 25

@warning_ignore("UNUSED_SIGNAL")
signal enemy_died


func _ready():
	attack_shape1.disabled = true
	attack_shape2.disabled = true
	attack_shape3.disabled = true
	
func _physics_process(_delta):
	# Movimiento SIEMPRE, no solo cuando detecta al jugador
	if current_health <= 0:
		return  # No hace nada si está muerto
	
	# Si el enemigo detecta al jugador, y no está atacando ni recibiendo daño, ataca
	if detect_zone.overlaps_body(player) and not is_attacking and not is_hurt:
		velocity = Vector2.ZERO
		move_and_slide()
		await attack_if_possible()
	else:
		movement()
		

func movement():
	if is_attacking or is_hurt:
		return  # No se mueve si está atacando o recibiendo daño
	
	var direction = global_position.direction_to(player.global_position).normalized()
	velocity = direction * 50
	move_and_slide()

	if velocity.length() > 0:
		sprite.play("WALK")
		if velocity.x != 0:
			var facing_right = velocity.x > 0
			sprite.scale.x = 1 if facing_right else -1
			
			if facing_right:
				# Restaurar escala y posición originales para evitar colisiones mal colocadas
				attack_shape1.scale.x = 1
				attack_shape2.scale.x = 1
				attack_shape3.scale.x = 1
				attack_shape1.position = Vector2(48, attack_shape1.position.y)
				attack_shape2.position = Vector2(46, attack_shape2.position.y)
				attack_shape3.position = Vector2(36, attack_shape3.position.y)
				
			else:
				# Invertir escala y ajustar posición para ataques a la izquierda
				attack_shape1.scale.x = -1
				attack_shape2.scale.x = -1
				attack_shape3.scale.x = -1
				attack_shape1.position = Vector2(20, attack_shape1.position.y)  
				attack_shape2.position = Vector2(22, attack_shape2.position.y) 
				attack_shape3.position = Vector2(32, attack_shape3.position.y)


func attack_if_possible():
	if not can_attack:
		return
	
	is_attacking = true
	can_attack = false
	
	# Ataque aleatorio 
	var attack_type = randi() % 3
	
	if attack_type == 0:
		attack_shape1.disabled = false
		attack_shape2.disabled = true
		attack_shape3.disabled = true
		await play_and_wait("ATTACK1")
		
	if attack_type == 1:
		attack_shape1.disabled = true
		attack_shape2.disabled = false
		attack_shape3.disabled = true
		await play_and_wait("ATTACK2")
		
	else:
		attack_shape1.disabled = true
		attack_shape2.disabled = true
		attack_shape3.disabled = false
		await play_and_wait("ATTACK3")
	
	attack_shape1.disabled = true
	attack_shape2.disabled = true
	attack_shape3.disabled = true
	

	can_attack = true
	is_attacking = false  # Resetear el estado de ataque después de la animación

func take_damage(damage_amount: int):
	if current_health <= 0:
		return
	
	current_health -= damage_amount
	print("Enemigo recibe daño. Vida restante:", current_health)
	
	# Detener el movimiento y reproducir animación de daño
	is_hurt = true
	velocity = Vector2.ZERO
	move_and_slide()
	
	await play_and_wait("HURT")
	
	is_hurt = false
	
	if current_health <= 0:
		await die()

func die():
	if is_dead:
		return
		
	is_dead = true
	is_attacking = true
	can_attack = false
	velocity = Vector2.ZERO
	move_and_slide()
	await play_and_wait("DEATH")
	
	#Drop de cristalito
	var exp_pickup = preload("res://Scenes/Crystals/pink_crystal.tscn").instantiate()
	exp_pickup.global_position = sprite.global_position
	get_tree().current_scene.add_child(exp_pickup)
	
	# Sumar puntos al global y actualizar la API
	Global.add_points(score_points)
	
	emit_signal("enemy_died")
	queue_free()

#Función para usar de forma recurrente el await
func play_and_wait(animation_name: String) -> void:
	sprite.play(animation_name)
	await sprite.animation_finished

#Función para atacar al jugador
func _on_attack_zone_body_entered(body):
	if body.name == "Player" and not (attack_shape1.disabled and attack_shape2.disabled and attack_shape3.disabled):
		body.take_damage(damage)
		
