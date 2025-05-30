extends ScrollContainer

@export var text_node: RichTextLabel
@export_range(1,100000,0.1) var credits_time: float = 1
@export_range(1,100000,0.1) var margin_increment: float = 0

@onready var margin = $MarginContainer
@onready var music = $"../Music"

func _ready():
	var tween = create_tween()
	var text_box_size = text_node.size.y
	var window_size = DisplayServer.window_get_size().y
	
	margin.add_theme_constant_override("margin_top", window_size + margin_increment)
	margin.add_theme_constant_override("margin_bottom", window_size + margin_increment)

	var scroll_amount = ceil(text_box_size * 3/4 + window_size * 2 + margin_increment)
	
	tween.tween_property(
		self,
		"scroll_vertical",
		scroll_amount,
		credits_time
	)
	
	tween.play()
	
	# Timer para cuando finalizan los credits
	var timer = Timer.new()
	timer.wait_time = 61.0
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(_on_credits_finished)
	timer.start()

func _on_credits_finished():
	get_tree().change_scene_to_file("res://Scenes/UI/menu_principal.tscn")
