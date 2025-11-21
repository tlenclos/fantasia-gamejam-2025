class_name Snowman extends Node3D

@onready var step_7: Node3D = $Step7
@onready var step_6: Node3D = $Step6
@onready var step_5: Node3D = $Step5
@onready var step_4: Node3D = $Step4
@onready var step_3: Node3D = $Step3
@onready var step_2: Node3D = $Step2
@onready var step_1: Node3D = $Step1

@export var snow_amount_for_next_step: int = 1
@export var current_step: int = 0

var player: Player
var snow_count: int = 0

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	if not is_multiplayer_authority():
		pass
	
	var newPosition = player.position
	newPosition.y = self.position.y
	look_at(newPosition)

func add_snow(amount: int = 1) -> void:
	snow_count += amount
	if snow_count >= snow_amount_for_next_step and current_step < 7:
		current_step += 1
		snow_count = 0

	step_1.visible = current_step >= 0
	step_2.visible = current_step >= 1
	step_2.visible = current_step >= 2
	step_3.visible = current_step >= 3
	step_4.visible = current_step >= 4
	step_5.visible = current_step >= 5
	step_6.visible = current_step >= 6
	step_7.visible = current_step >= 7

	if (current_step == 7):
		(get_tree().root.get_node("Main") as Main).win_game.rpc(player)

func reset() -> void:
	current_step = 0
	snow_count = 0
	step_1.visible = true
	step_2.visible = false
	step_3.visible = false
	step_4.visible = false
	step_5.visible = false
	step_6.visible = false
	step_7.visible = false
