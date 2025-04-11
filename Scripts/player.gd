extends CharacterBody2D

var movement_speed = 60.0
var weapon_reference = null  

func _physics_process(_delta):
	movement()
	aim_weapon()

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


#Función para apuntar en la dirección del ratón
func aim_weapon():
	if weapon_reference:
		var global_mouse_pos = get_global_mouse_position()
		var _dir = global_mouse_pos - global_position
		weapon_reference.look_at(global_mouse_pos)
			
