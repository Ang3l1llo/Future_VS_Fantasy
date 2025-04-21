extends CharacterBody2D

var movement_speed = 60.0
var weapon_reference = null  

func _physics_process(_delta):
	movement()
	aim_weapon()
	
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
		$AnimatedSprite2D.play("RUN")
	else:
		$AnimatedSprite2D.play("IDLE")

	#Para rotar al personaje si mira hacia un lado u otro
	if x_mov != 0:
		$AnimatedSprite2D.scale.x = 1 if x_mov > 0 else -1


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
