extends Area2D

@export var experience: int = 15
@onready var pick_up = $PickUpSound
@onready var gem_coll = $Gem_collision
@onready var animation = $AnimatedSprite2D

var attracted = false
var player = null
var speed = 600

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	$AnimatedSprite2D.play("idle")  
	add_to_group("Crystals")
	
func _process(delta):
	if attracted and player:
		var direction = (player.sprite.global_position - global_position).normalized()
		global_position += direction * speed * delta
	
func attract(player_ref):
	attracted = true
	player = player_ref

func _on_body_entered(body):
	if body.name == "Player":
		pick_up.play()
		body.gain_experience(experience)
		
		#Hago esto para evitar que la gema desaparezca sin reproducir el sonido
		gem_coll.set_deferred("disabled", true)
		animation.visible = false
		await get_tree().create_timer(0.4).timeout
		
		queue_free()
