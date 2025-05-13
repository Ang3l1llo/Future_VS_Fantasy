extends Node2D  

@export var lifetime: float = 2.0 

func _ready():
	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.play("idle")

	await get_tree().create_timer(lifetime).timeout
	queue_free()
