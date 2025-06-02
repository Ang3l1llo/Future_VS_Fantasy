extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D
@onready var death_sound = $Death
@onready var takeDamage_sound = $Take_damage
@onready var bloodEffect = $Blood
@onready var blood_anim = $Blood.get_node("AnimatedSprite2D")

var movement_speed = 100.0
var weapon_reference = null  
var max_health = 100
var current_health = max_health
var level = 1
var experience = 0
var experience_to_lvl = 10
var is_dead = false

# Diccionario de armas por mapa, para controlar que equipar al subir de nivel
var weapons_by_map = {
	"MeadowLands": [
		preload("res://Scenes/Weapons/Pistol.tscn"),
		preload("res://Scenes/Weapons/Pistol2.tscn"),
		preload("res://Scenes/Weapons/Subfusil.tscn"),
		preload("res://Scenes/Weapons/Shotgun3.tscn"),
		preload("res://Scenes/Weapons/Rifle.tscn"),
		preload("res://Scenes/Weapons/Rifle2.tscn")
	],
	"MisteryWoods": [
		preload("res://Scenes/Weapons/Pistol3.tscn"),
		preload("res://Scenes/Weapons/Pistol4.tscn"),
		preload("res://Scenes/Weapons/Subfusil2.tscn"),
		preload("res://Scenes/Weapons/Shotgun2.tscn"),
		preload("res://Scenes/Weapons/Rifle3.tscn"),
		preload("res://Scenes/Weapons/Rifle4.tscn")
	],
	"FinalZone": [
		preload("res://Scenes/Weapons/Pistol5.tscn"),
		preload("res://Scenes/Weapons/Pistol6.tscn"),
		preload("res://Scenes/Weapons/Shotgun.tscn"),
		preload("res://Scenes/Weapons/Rifle5.tscn"),
		preload("res://Scenes/Weapons/Rifle6.tscn"),
		preload("res://Scenes/Weapons/Supergun.tscn")
	]
}

@export var current_map = ""  # Para guardar el mapa actual
var current_weapon_index = 0  # Índice de la arma actual para saber cuál tiene euipada

func _physics_process(_delta):
	if is_dead:
		return
		
	movement()
	aim_weapon()
	handle_shooting()
	
	
#Función que controla el movimiento
func movement():
	var x_mov = Input.get_action_strength("right") - Input.get_action_strength("left")
	var y_mov = Input.get_action_strength("down") - Input.get_action_strength("up")
	var mov = Vector2(x_mov, y_mov)

	if mov.length() > 0:
		mov = mov.normalized()
		velocity = mov * movement_speed
		sprite.play("RUN")
		
		#Para rotar al personaje si mira hacia un lado u otro
		if x_mov != 0:
			sprite.scale.x = 1 if x_mov > 0 else -1
		
	else:
		velocity.x = move_toward(velocity.x, 0, movement_speed)
		velocity.y = move_toward(velocity.y, 0, movement_speed)
		sprite.play("IDLE")

	move_and_slide()
	
	
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
	if is_dead:
		return
		
	current_health -= amount
	takeDamage_sound.play()
	print("¡El jugador ha recibido daño! Vida actual:", current_health)
	
	#Efecto sangrado
	bloodEffect.visible = true
	blood_anim.play("bleed")
	await blood_anim.animation_finished
	bloodEffect.visible = false

	if current_health <= 0:
		die()


#Función para ganar exp
func gain_experience(amount: int):
	experience += amount
	print("Ganaste EXP:", amount, "- Total:", experience)
	if experience >= experience_to_lvl:
		level_up()


#Función de subida de lvl
func level_up():
	level += 1
	print("Subida de level")
	experience -= experience_to_lvl
	experience_to_lvl = int(experience_to_lvl * 2) #Ajustar con la dificultad relativa
	get_tree().paused = true
	show_menu_lvl_up()


#Función para mostrar el menú de subida de lvl
func show_menu_lvl_up():
	var menu_scene = preload("res://Scenes/UI/menu_lvl_up.tscn")
	var menu = menu_scene.instantiate() 
	var canvas_layer = get_tree().current_scene.get_node("LevelUpLayer")
	canvas_layer.add_child(menu)
	menu.show_menu(self)


#Función para mejorar arma a la siguiente
func upgrade_weapon():
	current_weapon_index += 1
	
	if current_weapon_index >= weapons_by_map[current_map].size():
		current_weapon_index = weapons_by_map[current_map].size() - 1  # Te quedas con la última arma
		print("Ya tienes el arma más poderosa.")
		return

	var weapon_scene = weapons_by_map[current_map][current_weapon_index]
	var weapon = weapon_scene.instantiate()
	
	weapon.global_position = sprite.global_position
	get_tree().current_scene.add_child(weapon)
	
	# Para el pequeño portal de las armas
	if weapon.has_node("CollisionShape2D"):
		var pivot_node := weapon.get_node("CollisionShape2D") as CollisionShape2D
		var portal_pos := pivot_node.global_position

		var portal_scene = preload("res://Scenes/portal.tscn")
		var portal = portal_scene.instantiate()
		portal.global_position = portal_pos
		portal.scale = Vector2(1.2, 1.2)
		portal.lifetime = 0.8

		get_tree().current_scene.add_child(portal)
	else:
		print("fallito")

	
#Para comprobar si tiene el mejor arma ya
func has_max_weapon() -> bool:
	return current_weapon_index >= weapons_by_map[current_map].size() - 1


#Función de muerte
func die():
	if is_dead:
		return
	is_dead = true

	velocity = Vector2.ZERO
	death_sound.play()
	sprite.play("DEATH")
	print("¡Game Over!")

	await sprite.animation_finished
	get_tree().change_scene_to_file("res://Scenes/UI/menu_death.tscn") 
	
