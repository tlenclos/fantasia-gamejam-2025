class_name SnowSpaner extends Node3D

@export var snowflake_scene: PackedScene
@export var beach_ball_scene: PackedScene
@export var spawn_delay_min: float = 1
@export var spawn_delay_max: float = 3

@onready var spawn_area_zone: MeshInstance3D = $SpawnAreaZone

var rng = RandomNumberGenerator.new()
var timer: Timer
var id = 0
# calculated from mesh
var spawn_area: Vector2 = Vector2(14, 8)
var spawn_height: float = 20.0
var spawn_center: Vector3 = Vector3.ZERO

func _ready():
	_calculate_spawn_area_from_mesh()

func _calculate_spawn_area_from_mesh():
	if spawn_area_zone and spawn_area_zone.mesh:
		var plane_mesh = spawn_area_zone.mesh
		var mesh_size = plane_mesh.size
		var mesh_transform = spawn_area_zone.global_transform
		var mesh_position = spawn_area_zone.position
		
		spawn_area = Vector2(mesh_size.x / 2.0, mesh_size.y / 2.0)
		spawn_height = mesh_position.y
		spawn_center = mesh_position

func start_spawning():
	if multiplayer.is_server():
		randomize()
		timer = Timer.new()
		add_child(timer)
		timer.one_shot = true
		timer.wait_time = randf_range(spawn_delay_min, spawn_delay_max)
		timer.timeout.connect(_on_spawn)
		timer.start()

func _on_spawn():
	var pos = Vector3(
		spawn_center.x + randf_range(-spawn_area.x, spawn_area.x),
		spawn_center.y + spawn_height,
		spawn_center.z + randf_range(-spawn_area.y, spawn_area.y)
	)
	var rand = rng.randf_range(0, 10.0)

	_spawn.rpc(pos, id, rand >= 9.0)
	id += 1

func stop_spawning():
	if multiplayer.is_server():
		timer.stop()

	# Clear snowflakes for all players
	_clear_snowflakes.rpc()

@rpc("any_peer", "call_local")
func _clear_snowflakes():
	# Clear all snowflakes
	for child in get_children():
		if child.is_in_group("Snowflakes") or child.is_in_group("BeachBall"):
			child.queue_free()

@rpc("any_peer", "call_local")
func _spawn(pos: Vector3, id: int, is_beach_ball: bool):
	if not snowflake_scene:
		return

	var object = null

	if is_beach_ball:
		object = beach_ball_scene.instantiate()
	else:
		object = snowflake_scene.instantiate()

	add_child(object)
	object.position = to_global(pos)
	# force name here to be constant across player, this ensure that is has the same path within godot so we can sync deletion
	object.name = "snowflake_" + str(id)

	if multiplayer.is_server():
		timer.wait_time = randf_range(spawn_delay_min, spawn_delay_max)
		timer.start()
