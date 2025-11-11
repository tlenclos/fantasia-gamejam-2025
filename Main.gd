extends Node3D

const PORT = 9999
const Player = preload("res://Player.tscn")
var enet_peer = ENetMultiplayerPeer.new()
var players: Dictionary[int, Player] = {}
var used_spawn_positions: Array[Vector3] = []

@onready var main_menu: PanelContainer = $MenuGroup/MainMenu
@onready var server_address_input: LineEdit = $MenuGroup/MainMenu/MarginContainer/VBoxContainer/ServerAddressInput

func _ready() -> void:
	if OS.has_feature("dedicated_server"):
		print("Starting dedicated server on port ", PORT)
		create_server()

func create_server() -> void:
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)

func _on_host_button_pressed() -> void:
	main_menu.hide()
	create_server()
	add_player(multiplayer.get_unique_id())

func _on_join_button_pressed() -> void:
	main_menu.hide()
	var host = "localhost"

	if server_address_input.text != "":
		host = server_address_input.text

	print("Connected to ", host)
	enet_peer.create_client(host, PORT)
	multiplayer.multiplayer_peer = enet_peer

func add_player(peer_id):
	# Server chose a spawn position and tells all clients
	if multiplayer.is_server():
		print('Player joined ', peer_id)
		var spawn_pos = get_spawn_position()
		used_spawn_positions.append(spawn_pos)
		spawn_player.rpc(peer_id, spawn_pos)

@rpc("any_peer", "call_local")
func spawn_player(peer_id: int, spawn_pos: Vector3):
	var player = Player.instantiate()
	player.name = str(peer_id)
	player.position = spawn_pos
	
	add_child(player)
	players[peer_id] = player

func remove_player(peer_id):
	if players.has(peer_id):
		var player = players[peer_id]
		used_spawn_positions.erase(player.position)
		remove_child(player)
		players.erase(peer_id)
			
func get_spawn_position() -> Vector3:
	var spawns = get_tree().get_nodes_in_group("SpawnPositions")
	if spawns.is_empty():
		return Vector3(0, 4, 5)
	
	for spawn in spawns:
		if not used_spawn_positions.has(spawn.position):
			return spawn.position
	
	return spawns.pick_random().position
