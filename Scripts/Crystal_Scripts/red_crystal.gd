extends Area2D

@export var experience: int = 50

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	$AnimatedSprite2D.play("idle")  

func _on_body_entered(body):
	if body.name == "Player":
		body.gain_experience(experience)
		queue_free()
