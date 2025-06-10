extends Area2D

var speed = 400.0
var direction = Vector2.ZERO
var damage = 0 #Recibirá el daño del arma correspondiente
var shooting = false

func _ready():
	direction = Vector2.RIGHT.rotated(rotation)
	visible = false
	shooting = false

func _physics_process(delta):
	if shooting:
		visible = true
		position += direction * speed * delta

func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()

#Para evitar que la bala que se instancia en el arma dispare la primera vez desde el suelo
func activate_shooting():
	shooting = true
	visible = true
	direction = Vector2.RIGHT.rotated(rotation)
