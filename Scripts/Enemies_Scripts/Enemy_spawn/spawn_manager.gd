extends Node

@export var player_path: NodePath
@export var trees_tilemap_path: NodePath
@export var enemy_scene: Array[PackedScene] = []
@export var spawn_area_rect: Rect2  # Zona segura
@export var spawn_distance_min: float = 400.0  # Distancia mínima al jugador
@export var spawn_distance_max: float = 600.0  # Distancia máxima al jugador
@export var max_enemies: int = 10
@export var spawn_interval: float = 3.0
@export var enemies_per_spawn: int = 2

var player: Node2D
var trees: TileMapLayer
var current_enemies: Array = []
var spawn_timer: float = 0.0

func _ready():
	player = get_node(player_path)
	trees = get_node(trees_tilemap_path)

func _process(delta):
	if not player:
		return

	#Comprobaciones de tiempo y cantidad de enemigos
	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_timer = 0.0
		if current_enemies.size() < max_enemies:
			spawn_enemies()

# --- SPAWN DE ENEMIGOS ---
func spawn_enemies():
	for i in enemies_per_spawn:
		var _spawned = false
		for attempt in range(50):
			var pos = get_random_spawn_position()
			if is_valid_spawn(pos):
				var enemy = enemy_scene.pick_random().instantiate()
				enemy.global_position = pos
				get_parent().add_child(enemy)
				current_enemies.append(enemy)

				if enemy.has_signal("enemy_died"):
					enemy.connect("enemy_died", Callable(self, "_on_enemy_died").bind(enemy))

				_spawned = true
				break

# --- POSICIÓN ALEATORIA DENTRO DE ZONA SEGURA Y A CIERTA DISTANCIA DEL JUGADOR ---
func get_random_spawn_position() -> Vector2:
	var rect = spawn_area_rect
	var random_distance = randf_range(spawn_distance_min, spawn_distance_max)  # Generar distancia aleatoria
	var angle = randf() * TAU  # Dirección aleatoria
	var offset = Vector2.RIGHT.rotated(angle) * random_distance 

	var spawn_pos = player.global_position + offset #Se comprueba donde esta el jugador y se le añade el offset

	for _i in range(50):
		if spawn_area_rect.has_point(spawn_pos) and spawn_pos.distance_to(player.global_position) >= spawn_distance_min and spawn_pos.distance_to(player.global_position) <= spawn_distance_max:
			return spawn_pos

	# Por si no encontrase posición válida, se genera una random en zona segura
	spawn_pos = Vector2(
		randf_range(rect.position.x, rect.position.x + rect.size.x),
		randf_range(rect.position.y, rect.position.y + rect.size.y)
	)
	return spawn_pos

# Para evitar spawn en arbolitos
func is_valid_spawn(pos: Vector2) -> bool:
	var tile_pos = trees.local_to_map(pos)
	return trees.get_cell_source_id(tile_pos) == -1  

# Conteo de enemigos que mueren
func _on_enemy_died(enemy):
	if enemy in current_enemies:
		current_enemies.erase(enemy)
