extends CharacterBody2D

@onready var player = get_node("/root/Map1/Player")
@onready var sprite = $AnimatedSprite2D
@onready var attack_zone = $AttackZone
@onready var attack_shape = attack_zone.get_node("Attack1") 
@onready var detect_zone = $DetectZone

var can_attack = true
var is_attacking = false
var is_hurt = false
var max_health = 100
var current_health = max_health
var damage = 20


func _physics_process(_delta):
	if current_health <= 0:
		return
	
	if detect_zone.overlaps_body(player) and not is_attacking and not is_hurt:
		velocity = Vector2.ZERO
		move_and_slide()
		await attack_if_possible()
	else:
		movement()

func movement():
	if is_attacking or is_hurt:
		return
	
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * 50
	move_and_slide()

	if velocity.length() > 0:
		sprite.play("WALK")
		if velocity.x != 0:
			sprite.scale.x = 1 if velocity.x > 0 else -1
			
			if sprite.scale.x > 0:
				# Mirando a la derecha
				attack_shape.position = Vector2(49, attack_shape.position.y)
				attack_shape.scale.x = 1
			else:
				# Mirando a la izquierda
				attack_shape.position = Vector2(20, attack_shape.position.y)
				attack_shape.scale.x = -1


func attack_if_possible():
	if not can_attack:
		return
	
	is_attacking = true
	can_attack = false
	
	attack_shape.disabled = false
	await play_and_wait("ATTACK1")
	attack_shape.disabled = true
	
	can_attack = true
	is_attacking = false

func take_damage(damage_amount: int):
	if current_health <= 0:
		return
	
	current_health -= damage_amount
	print("Enemigo recibe daño. Vida restante:", current_health)
	
	is_hurt = true
	velocity = Vector2.ZERO
	move_and_slide()
	
	await play_and_wait("HURT")
	is_hurt = false
	
	if current_health <= 0:
		await die()

func die():
	is_attacking = true
	can_attack = false
	velocity = Vector2.ZERO
	move_and_slide()
	await play_and_wait("DEATH")
	queue_free()

func play_and_wait(animation_name: String) -> void:
	sprite.play(animation_name)
	await sprite.animation_finished

func _on_attack_zone_body_entered(body):
	if body.name == "Player" and not attack_shape.disabled:
		body.take_damage(damage)
