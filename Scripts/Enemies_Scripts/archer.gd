extends CharacterBody2D

@onready var player = get_node("/root/MeadowLands/Player") 
@onready var sprite = $AnimatedSprite2D
@onready var detect_zone = $DetectZone
@onready var arrow_spawn = $ArrowSpawnPoint
@export var arrow_scene: PackedScene

var can_attack = true
var is_attacking = false
var is_hurt = false
var max_health = 100
var current_health = max_health
var speed = 50

signal enemy_died

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
	
	var direction = global_position.direction_to(player.global_position).normalized()
	velocity = direction * speed
	move_and_slide()

	if velocity.length() > 0:
		sprite.play("WALK")
		if velocity.x != 0:
			sprite.scale.x = 1 if velocity.x > 0 else -1

func attack_if_possible():
	if not can_attack:
		return
	
	is_attacking = true
	can_attack = false
	
	await play_and_wait("ATTACK1")
	
	shoot_projectile()
	can_attack = true
	is_attacking = false

func shoot_projectile():
	var arrow = arrow_scene.instantiate()
	get_tree().current_scene.add_child(arrow)
	
	# Sale desde el arquero
	arrow.global_position = arrow_spawn.global_position
	
	# Dirección hacia el jugador
	var dir = (player.global_position - global_position).normalized()
	arrow.direction = dir
	
	arrow.rotation = dir.angle()

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
	
	#Drop de cristalito
	var exp_pickup = preload("res://Scenes/Crystals/Blue_crystal.tscn").instantiate()
	exp_pickup.global_position = sprite.global_position
	get_tree().current_scene.add_child(exp_pickup)
	
	emit_signal("enemy_died")
	queue_free()

func play_and_wait(animation_name: String) -> void:
	sprite.play(animation_name)
	await sprite.animation_finished
