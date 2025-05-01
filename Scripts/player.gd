extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D
var movement_speed = 200.0
var weapon_reference = null  
var max_health = 100
var current_health = max_health
var is_dead = false


func _physics_process(_delta):
	if is_dead:
		return
		
	movement()
	aim_weapon()
	handle_shooting()
	#Esto fuerza la posición del jugador a estar en valores enteros de píxeles, evitando lag
	global_position = global_position.round()
	
#Función que controla el movimiento
func movement():
	var x_mov = Input.get_action_strength("right") - Input.get_action_strength("left")
	var y_mov = Input.get_action_strength("down") - Input.get_action_strength("up")
	var mov = Vector2(x_mov, y_mov)
	velocity = mov.normalized() * movement_speed
	move_and_slide()
	
	if mov.length() > 0:
		sprite.play("RUN")
	else:
		sprite.play("IDLE")

	#Para rotar al personaje si mira hacia un lado u otro
	if x_mov != 0:
		sprite.scale.x = 1 if x_mov > 0 else -1


#Función para apuntar 
func aim_weapon():
	if weapon_reference:
		var global_mouse_pos = get_global_mouse_position()
		weapon_reference.look_at(global_mouse_pos) #Para que apunte en la dirección que este el ratón
		
		#Para rotar el arma cuando apunte hacia la otra dirección y no se vea volteada
		var angle_deg = wrap(weapon_reference.rotation_degrees, 0, 360)

		if angle_deg > 90 and angle_deg < 270:
			weapon_reference.scale.y = -1
		else:
			weapon_reference.scale.y = 1

#Función para manejar el disparo
func handle_shooting():
	if Input.is_action_just_pressed("shoot") and weapon_reference:
		weapon_reference.shoot()

#Función para recibir daño de los enemigos
func take_damage(amount):
	current_health -= amount
	print("¡El jugador ha recibido daño! Vida actual:", current_health)

	if current_health <= 0:
		die()

func die():
	if is_dead:
		return
	is_dead = true

	velocity = Vector2.ZERO
	sprite.play("DEATH")
	print("¡Game Over!")

	await sprite.animation_finished
