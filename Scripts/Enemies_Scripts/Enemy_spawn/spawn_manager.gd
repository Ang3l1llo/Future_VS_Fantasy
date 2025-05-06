extends Node

@export var player_path: NodePath
@export var ground_tilemap_path: NodePath
@export var water_tilemap_path: NodePath
@export var enemy_scene: Array[PackedScene] = []
@export var spawn_distance: float = 400.0
@export var max_enemies: int = 10
@export var spawn_interval: float = 3.0
@export var enemies_per_spawn: int = 2

var player: Node2D
var ground: TileMapLayer
var water: TileMapLayer
var current_enemies: Array = []

var spawn_timer: float = 0.0

func _ready():
	player = get_node(player_path)
	ground = get_node(ground_tilemap_path)
	water = get_node(water_tilemap_path)

func _process(delta):
	if not player:
		return

	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_timer = 0.0
		if current_enemies.size() < max_enemies:
			spawn_enemies()

# --- SPANWN DE ENEMIGOS ---
func spawn_enemies():
	var attempts = 10  # número máximo de intentos para encontrar una posición válida

	for i in enemies_per_spawn:
		var spawned = false
		while not spawned and attempts > 0:
			attempts -= 1
			var pos = get_random_spawn_position()
			if is_valid_spawn(pos):
				var scene = enemy_scene.pick_random()
				var enemy = scene.instantiate()
				enemy.global_position = pos
				get_parent().add_child(enemy)
				current_enemies.append(enemy)

				# Si el enemigo tiene método para notificar muerte, conectar señal
				if enemy.has_signal("enemy_died"):
					enemy.connect("enemy_died", Callable(self, "_on_enemy_died").bind(enemy))

				spawned = true

# --- POSICIÓN ALEATORIA FUERA DE LA CÁMARA ---
func get_random_spawn_position() -> Vector2:
	var angle = randf() * TAU
	var offset = Vector2.RIGHT.rotated(angle) * spawn_distance
	return player.global_position + offset

# --- SOLO PERMITIR TILE DE TIERRA ---
func is_valid_spawn(pos: Vector2) -> bool:
	var tile_pos = ground.local_to_map(pos)
	var tile_data = ground.get_cell_tile_data(tile_pos)
	if tile_data == null:
		return false  # No hay tierra, no válido
	
	var water_tile_pos = water.local_to_map(pos)
	var water_data = water.get_cell_tile_data(water_tile_pos)
	if water_data != null:
		return false  # Hay agua, no válido

	return true  # Hay tierra y no hay agua


# --- ENEMIGO ELIMINADO ---
func _on_enemy_died(enemy):
	if enemy in current_enemies:
		current_enemies.erase(enemy)
