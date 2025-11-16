class_name Snowman extends Node3D

# TODO add eyes, node and carrot

@onready var snowman_step_0: Node3D = $Snowman_step0
@onready var snowman_step_1: Node3D = $Snowman_step1
@onready var snowman_step_2: Node3D = $Snowman_step2
@onready var snowman_step_3: Node3D = $Snowman_step3

@export var snow_step_needed: int = 5
@export var current_step: int = 0

var snowman_peer_id: int
var snow_count: int = 0

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass

func add_snow(amount: int = 1) -> void:
	snow_count += amount
	if snow_count >= snow_step_needed and current_step < 3:
		current_step += 1
		snow_count = 0

	snowman_step_0.visible = current_step >= 0
	snowman_step_1.visible = current_step >= 1
	snowman_step_2.visible = current_step >= 2
	snowman_step_3.visible = current_step >= 3
