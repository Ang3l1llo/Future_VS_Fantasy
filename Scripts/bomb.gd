extends Area2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
var explosion_effect_scene = preload("res://Scenes/explosion_effect.tscn") 
@onready var explosion_sound = $BombSound

var exploded = false

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	$AnimatedSprite2D.play("idle")
	sprite.connect("animation_finished", Callable(self, "_on_animation_finished"))

func _on_body_entered(body):
	if exploded:
		return
		
	if body.name == "Player":
		explosion_sound.play()
		exploded = true
		sprite.play("explosion")
		await sprite.animation_finished
		
		
		# Instanciar el efecto visual de explosión
		var explosion_effect = explosion_effect_scene.instantiate()
		explosion_effect.global_position = global_position
		get_tree().current_scene.add_child(explosion_effect)
		

		
		delete_enemies()

func delete_enemies():
	var root = get_tree().get_current_scene()
	var enemies = root.get_tree().get_nodes_in_group("Enemies")
	for enemy in enemies:
		enemy.die()

func _on_animation_finished():
	if sprite.animation == "explosion":
		queue_free()
