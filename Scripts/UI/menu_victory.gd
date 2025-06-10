extends Control

@onready var button_continue = $Button_continue
@onready var button_exit = $Button_exit
@onready var music = $Music
@onready var Bt_continue = $Bt_continue
@onready var Bt_exit = $Bt_exit
var can_interact := false

func _ready():
	await get_tree().process_frame
	can_interact = true

func _on_bt_continue_pressed():
	if !can_interact or !is_inside_tree():
		print("Botón ignorado: aún no se puede interactuar o nodo fuera del árbol")
		return
	
	can_interact = false  # Prevenir interacciones futuras
	Bt_continue.disabled = true
	Bt_exit.disabled = true  # También desactiva el otro por si acaso
	
	if music.playing:
		await music.finished
	button_continue.play()
	await button_continue.finished
	
	var level_name = Global.current_level.get_file().get_basename()
	Global.save_progress(level_name)
	
	var current_scene = Global.current_level
	var next_scene = ""

	if current_scene == "res://Scenes/Levels/MeadowLands.tscn":
		next_scene = "res://Scenes/Levels/MisteryWoods.tscn"
	elif current_scene == "res://Scenes/Levels/MisteryWoods.tscn":
		next_scene = "res://Scenes/Levels/FinalZone.tscn"
	else:
		next_scene = "res://Scenes/UI/final_lore.tscn"

	Global.score_at_level_start = Global.score
	
	var tree := get_tree()
	if tree:
		tree.change_scene_to_file(next_scene)
	else:
		print("Error: get_tree() devolvió null")

func _on_bt_exit_pressed():
	if !can_interact or !is_inside_tree():
		print("Botón ignorado: aún no se puede interactuar o nodo fuera del árbol")
		return
	
	can_interact = false
	Bt_continue.disabled = true
	Bt_exit.disabled = true
	
	if music.playing:
		await music.finished
	button_exit.play()
	await button_exit.finished
	get_tree().change_scene_to_file("res://Scenes/UI/menu_principal.tscn")
