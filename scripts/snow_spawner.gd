# SnowSpawner_simple.gd
extends Node3D

@export var snowflake_scene: PackedScene
@export var spawn_area: Vector2 = Vector2(20, 20) # x/z half extents
@export var spawn_height: float = 20.0
@export var max_count: int = 150
@export var spawn_delay_min: float = 1  # minimum seconds between spawns
@export var spawn_delay_max: float = 3   # maximum seconds between spawns

var _active_count: int = 0
var _spawn_timer: Timer

func _ready():
	randomize()
	_spawn_timer = Timer.new()
	add_child(_spawn_timer)
	_spawn_timer.one_shot = true
	_spawn_timer.wait_time = randf_range(spawn_delay_min, spawn_delay_max)
	_spawn_timer.autostart = true
	_spawn_timer.connect("timeout", Callable(self, "_on_spawn_timer"))
	_spawn_timer.start()

func _on_spawn_timer():
	if _active_count < max_count:
		_spawn_one()
	# schedule next spawn (random interval)
	_spawn_timer.wait_time = randf_range(spawn_delay_min, spawn_delay_max)
	_spawn_timer.start()

func _spawn_one():
	if not snowflake_scene:
		return
	var flake = snowflake_scene.instantiate()
	add_child(flake)
	_active_count += 1

	# random X/Z inside spawn_area, random rotation, small random velocity
	var x = randf_range(-spawn_area.x, spawn_area.x)
	var z = randf_range(-spawn_area.y, spawn_area.y)
	flake.global_transform.origin = Vector3(x, spawn_height, z)

	if flake is RigidBody3D:
		flake.linear_velocity = Vector3(randf_range(-0.2, 0.2), randf_range(-0.1, -0.4), randf_range(-0.2, 0.2))
		flake.angular_velocity = Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)) * 0.3

func _on_flake_exited(flake):
	_active_count = max(0, _active_count - 1)
