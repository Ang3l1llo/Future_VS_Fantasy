extends Area2D

var attracted = false
@onready var magnet_sound = $MagnetSound
@onready var magnet_sprite = $Sprite2D
func _ready():
	update_animation("floating")
	connect("body_entered", Callable(self, "_on_body_entered"))
	
func _on_body_entered(body):
	if body.name == "Player":
		magnet_sound.play()
		activate_magnet(body)
		magnet_sprite.visible = false
		await magnet_sound.finished
		queue_free()

func activate_magnet(player):
	var crystals = get_tree().get_nodes_in_group("Crystals") 
	for crystal in crystals:
		crystal.attract(player)

func update_animation(animation):
	$Sprite2D/AnimationPlayer.play(animation)
