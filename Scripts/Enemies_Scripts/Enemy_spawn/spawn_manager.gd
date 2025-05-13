extends Node2D

@export var player_path: NodePath
@export var trees_tilemap_path: NodePath
@export var spawn_area_rect: Rect2
@export var spawn_distance_min: float = 400.0
@export var spawn_distance_max: float = 600.0
@export var max_enemies: int = 10
@export var spawn_interval: float = 3.0
@export var enemies_per_spawn: int = 2
@export var current_map: String = "MeadowLands"  # Esto tengo que modificarlo en editor para otros maps

var player: Node2D
var trees: TileMapLayer
var current_enemies: Array = []
var spawn_timer: float = 0.0

# Enemigos por mapa con proporciones
var enemies_by_map = {
	"MeadowLands": {
		preload("res://Scenes/Enemies/Archer.tscn"): 0.5,
		preload("res://Scenes/Enemies/ArmoredAxeman.tscn"): 0.5,
		preload("res://Scenes/Enemies/knight.tscn"): 0.3,
		preload("res://Scenes/Enemies/knightTemplar.tscn"): 0.3,
		preload("res://Scenes/Enemies/SwordMan.tscn"): 0.2,
		preload("res://Scenes/Enemies/Lancer.tscn"): 0.1
	},
	"MisteryWoods": {
		preload("res://Scenes/Enemies/Skeleton.tscn"): 0.5,
		preload("res://Scenes/Enemies/SkeletonArcher.tscn"): 0.5,
		preload("res://Scenes/Enemies/ArmoredSkeleton.tscn"): 0.3,
		preload("res://Scenes/Enemies/Slime.tscn"): 0.4,
		preload("res://Scenes/Enemies/GreatSwordSkeleton.tscn"): 0.2
	},
	"FinalZone": {
		preload("res://Scenes/Enemies/orc.tscn"): 0.5,
		preload("res://Scenes/Enemies/ArmoredOrc.tscn"): 0.4,
		preload("res://Scenes/Enemies/EliteOrc.tscn"): 0.3,
		preload("res://Scenes/Enemies/WereWolf.tscn"): 0.3,
		preload("res://Scenes/Enemies/OrcRider.tscn"): 0.2,
		preload("res://Scenes/Enemies/WereBear.tscn"): 0.2,
		preload("res://Scenes/Enemies/Wizard.tscn"): 0.1
	}
}

func _ready():
	player = get_node(player_path)
	trees = get_node(trees_tilemap_path)

func _process(delta):
	if not player:
		return

	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_timer = 0.0
		if current_enemies.size() < max_enemies:
			spawn_enemies()

func spawn_enemies():
	for i in enemies_per_spawn:
		var _spawned = false
		for attempt in range(100): #Pongo muchos intentos para aumentar la probabilidad de que salga bien
			var pos = get_random_spawn_position()
			print("Intento de spawn en:", pos)

			if is_valid_spawn(pos):
				print("Posición válida encontrada:", pos)

				var enemy = pick_enemy(current_map).instantiate()
				enemy.global_position = pos
				get_parent().add_child(enemy)
				current_enemies.append(enemy)

				if enemy.has_signal("enemy_died"):
					enemy.connect("enemy_died", Callable(self, "_on_enemy_died").bind(enemy))

				_spawned = true
				break

#Para elegir de forma aleatoria el enemigo
func pick_enemy(map_name: String) -> PackedScene:
	var pool = []
	for enemy_scene in enemies_by_map.get(map_name, {}).keys():
		var weight = enemies_by_map[map_name][enemy_scene] * 100
		for i in int(weight):
			pool.append(enemy_scene)
	return pool.pick_random()

#Para elegir un spot aleatorio del enemigo
func get_random_spawn_position() -> Vector2:
	var rect = spawn_area_rect
	var random_distance = randf_range(spawn_distance_min, spawn_distance_max)
	var angle = randf() * TAU
	var offset = Vector2.RIGHT.rotated(angle) * random_distance

	var spawn_pos = player.global_position + offset

	for _i in range(50):
		if spawn_area_rect.has_point(spawn_pos) and spawn_pos.distance_to(player.global_position) >= spawn_distance_min and spawn_pos.distance_to(player.global_position) <= spawn_distance_max:
			return spawn_pos

	spawn_pos = Vector2(
		randf_range(rect.position.x, rect.position.x + rect.size.x),
		randf_range(rect.position.y, rect.position.y + rect.size.y)
	)
	return spawn_pos

#Para comprobar si ese spot es válido
func is_valid_spawn(pos: Vector2) -> bool:
	var test_shape = CircleShape2D.new()
	test_shape.radius = 10

	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = test_shape
	query.transform = Transform2D(0, pos)
	query.collision_mask = 1 << 4

	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_shape(query)

	if result.size() > 0:
		print("Colisión detectada en spawn con árboles:", result)
		return false

	return true

func _on_enemy_died(enemy):
	if enemy in current_enemies:
		current_enemies.erase(enemy)
