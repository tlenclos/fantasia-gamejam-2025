class_name SnowSpaner extends Node3D

@export var snowflake_scene: PackedScene

@export var spawn_center: Vector3 = Vector3(0, 0, 5) # anchor point of the spawner with (x,y,z), z being the depth (forward/back)
@export var spawn_area: Vector2 = Vector2(14, 8) # width (left/right)
@export var spawn_height: float = 20.0 # in the sky (up/down)

@export var spawn_delay_min: float = 1
@export var spawn_delay_max: float = 3

var timer: Timer
var id = 0

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
	_spawn.rpc(pos, id)
	id += 1

@rpc("any_peer", "call_local")
func _spawn(pos: Vector3, id: int):
	if not snowflake_scene:
		return
	var flake = snowflake_scene.instantiate()
	add_child(flake)
	flake.position = to_global(pos)
	# force name here to be constant across player, this ensure that is has the same path within godot so we can sync deletion
	flake.name = "snowflake_" + str(id)

	if multiplayer.is_server():
		timer.wait_time = randf_range(spawn_delay_min, spawn_delay_max)
		timer.start()
