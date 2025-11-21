extends RigidBody3D

@export var velocity:Vector3
@export var player_group := "player"

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if not multiplayer.is_server():
		return

	var contact_count := state.get_contact_count()

	for i in range(contact_count):
		var collider := state.get_contact_collider_object(i)

		if collider and collider.is_in_group("Players"):
			state.apply_impulse(state.get_contact_local_normal(i))
