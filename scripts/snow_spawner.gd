class_name SnowSpaner extends Node3D

@export var snowflake_scene: PackedScene

@export var spawn_center: Vector3 = Vector3(0, 0, 5) # anchor point of the spawner with (x,y,z), z being the depth (forward/back)
@export var spawn_area: Vector2 = Vector2(14, 8) # width (left/right)
@export var spawn_height: float = 20.0 # in the sky (up/down)

@export var spawn_delay_min: float = 1
@export var spawn_delay_max: float = 3

var timer: Timer

func start_spawning():
	if multiplayer.is_server():
		randomize()
		timer = Timer.new()
		add_child(timer)
		timer.one_shot = true
		timer.wait_time = randf_range(spawn_delay_min, spawn_delay_max)
		timer.timeout.connect(_spawn.rpc)
		timer.start()

@rpc("any_peer", "call_local")
func _spawn():
	if not snowflake_scene:
		return
	var flake = snowflake_scene.instantiate()
	add_child(flake)
	var pos = Vector3(
		spawn_center.x + randf_range(-spawn_area.x, spawn_area.x),
		spawn_center.y + spawn_height,
		spawn_center.z + randf_range(-spawn_area.y, spawn_area.y)
	)
	flake.position = to_global(pos)
	
	if multiplayer.is_server():
		timer.wait_time = randf_range(spawn_delay_min, spawn_delay_max)
		timer.start()
