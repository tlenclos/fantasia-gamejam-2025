extends Node3D

@export var snowflake_scene: PackedScene
@export var spawn_area: Vector3 = Vector3(20, 0, 20)
@export var spawn_height: float = 20
@export var spawn_count: int = 100

func _ready():
	randomize()
	for i in spawn_count:
		spawn_snowflake()

func spawn_snowflake():
	var snowflake = snowflake_scene.instantiate()
	add_child(snowflake)
	
	# random position within area
	var x = randf_range(-spawn_area.x, spawn_area.x)
	var z = randf_range(-spawn_area.z, spawn_area.z)
	snowflake.global_transform.origin = Vector3(x, spawn_height, z)
	
	# optional random rotation
	snowflake.rotation_degrees = Vector3(randf()*360, randf()*360, randf()*360)
