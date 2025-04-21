extends CharacterBody2D

@onready var player = get_node("/root/Map1/Player")
@onready var sprite = $AnimatedSprite2D
@onready var attack_zone = $AttackZone
@onready var attack_shape1 = attack_zone.get_node("Attack1")
@onready var attack_shape2 = attack_zone.get_node("Attack2")
@onready var detect_zone = $DetectZone

var can_attack = true
var attack_cooldown = 1

func _physics_process(_delta):
	if detect_zone.overlaps_body(player):
		velocity = Vector2.ZERO
		move_and_slide()
		attack_if_possible()
	else:
		movement()

func movement():
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * 50
	move_and_slide()

	if velocity.length() > 0:
		sprite.play("WALK")
		if velocity.x != 0:
			sprite.scale.x = 1 if velocity.x > 0 else -1

func attack_if_possible():
	if not can_attack:
		return
	
	can_attack = false
	
	var attack_type = randi() % 2  # 0 o 1

	if attack_type == 0:
		sprite.play("ATTACK1")
		attack_shape1.disabled = false
		attack_shape2.disabled = true
	else:
		sprite.play("ATTACK2")
		attack_shape1.disabled = true
		attack_shape2.disabled = false
	
	await get_tree().create_timer(0.5).timeout
	attack_shape1.disabled = true
	attack_shape2.disabled = true

	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true
