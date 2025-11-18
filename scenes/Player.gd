class_name Player extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var isGrowing = false
var initialScale = Vector3(1, 1, 1)
# TODO Prevent players having the same color
const playersColor = [
	Color(0.672, 0.0, 0.0, 1.0),
	Color(0.598, 0.932, 0.953, 1.0),
	Color(0.186, 0.169, 0.867, 1.0),
	Color(0.86, 0.434, 0.368, 1.0),
	Color(0.32, 0.847, 0.185, 1.0),
	Color(0.814, 0.758, 0.054, 1.0),
]

@export var growingFactor = 0.5
@export var reducingFactor = 0.01
@export var color = Color(0, 0, 0): set = set_color
@onready var body: MeshInstance3D = $Body

func _ready() -> void:
	initialScale = scale

	if not is_multiplayer_authority(): return

	color = playersColor[randi() % playersColor.size()]

func _enter_tree() -> void:
	set_multiplayer_authority(str(name).to_int())

func _input(event: InputEvent) -> void:
	if not is_multiplayer_authority(): return
	if event is InputEventMouseButton and event.is_pressed():
		grow()

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority(): return

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	# Rotate the player to face the movement direction
	var target_rotation = atan2(direction.x, direction.z)
	body.rotation.y = target_rotation

	move_and_slide()

	# Ungrow
	if isGrowing:
		scale -= Vector3(reducingFactor, reducingFactor, reducingFactor)
		if scale.x < initialScale.x:
			isGrowing = false

func grow() -> void:
	isGrowing = true
	if scale.x > 2: return

	scale += Vector3(growingFactor, growingFactor, growingFactor)

func set_color(new_color: Color) -> void:
	color = new_color
	_apply_color()

func _apply_color() -> void:
	# this can be called before _ready() during replication by MultiplayerSpawner
	if not body or OS.has_feature("dedicated_server"):
		return

	var material = body.get_surface_override_material(0)
	if not material:
		if body.mesh and body.mesh.surface_get_material(0):
			material = body.mesh.surface_get_material(0).duplicate()
		else:
			material = StandardMaterial3D.new()
		body.set_surface_override_material(0, material)

	material.albedo_color = color

func _on_area_3d_body_entered(node: Node3D) -> void:
	if multiplayer.is_server() and node.is_in_group("Snowflakes"):
		(get_tree().root.get_node("Main") as Main).add_snow_to_player.rpc(int(self.name), node.get_path())
