extends Area2D

@export var speed: float = 200.0
@export var damage: int = 10
var direction = Vector2.ZERO

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if body.name == "Player":
		body.take_damage(damage)
		queue_free()
