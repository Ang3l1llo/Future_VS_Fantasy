extends Area2D

var speed = 400.0
var direction = Vector2.ZERO
var damage = 0 #Recibirá el daño del arma correspondiente

func _ready():
	direction = Vector2.RIGHT.rotated(rotation)

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	print("Bala impacta a:", body.name)
	if body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()
