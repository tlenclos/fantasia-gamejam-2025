extends RigidBody3D

func _ready():
	var area = get_node_or_null("Area3D")
	if area:
		area.body_entered.connect(_handle_player_collision)

func _handle_player_collision(body: Node3D):
	if body.is_in_group("Players"):
		queue_free()
