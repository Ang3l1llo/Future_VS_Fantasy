extends Area2D

@export var speed: float = 200.0
@export var damage: int = 40
@export var lifetime: float = 10.0 # Tiempo máximo de vida de la flechita
var direction = Vector2.ZERO

func _ready():
	# Comienza la cuenta atrás
	await get_tree().create_timer(lifetime).timeout
	queue_free()
	
func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if body.name == "Player":
		body.take_damage(damage)
	queue_free()
