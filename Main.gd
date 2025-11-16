class_name Main extends Node3D

const PlayerScene = preload("res://scenes/Player.tscn")
const SnowmanScene = preload("res://scenes/Snowman.tscn")

const PORT = 9999
var enet_peer = ENetMultiplayerPeer.new()
var used_spawn_positions: Array[Vector3] = []
var host = "localhost"
var isDedicatedServer = OS.has_feature("dedicated_server")
var gameStarted = false
var isServer = false

@export var game_timer: int = 10
@onready var main_menu: PanelContainer = $MenuGroup/MainMenu
@onready var game_ui: CanvasLayer = $GameUIGroup
@onready var game_ui_bottom_label: Label = $GameUIGroup/GameUI/MarginContainer/VBoxContainer/Label
@onready var server_address_input: LineEdit = $MenuGroup/MainMenu/MarginContainer/VBoxContainer/ServerAddressInput
@onready var error_label: Label = $MenuGroup/MainMenu/MarginContainer/VBoxContainer/ErrorLabel
@onready var phantom_camera_3d: PhantomCamera3D = $PhantomCamera3D
@onready var start_game_circle: MeshInstance3D = $StartGameCircle
@onready var start_game_area: Area3D = $StartGameCircle/StartGameArea
@onready var snow_spawner: SnowSpaner = $SnowSpawner

func _ready() -> void:
	if isDedicatedServer:
		print("Starting dedicated server on port ", PORT)
		create_server()

func _physics_process(_delta: float) -> void:
	var all_players = get_all_players()
	if not gameStarted and all_players.size() > 0 and start_game_area != null and start_game_area.get_overlapping_bodies().filter(func(body): return body is Player).size() == all_players.size():
		start_game()
		
	# TODO Check win conditions here
		
func create_server() -> void:
	var error = enet_peer.create_server(PORT)
	if error != OK:
		print('Error starting server: ', error)
		return

	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	isServer = true

func _on_host_button_pressed() -> void:
	error_label.text = ""
	main_menu.hide()
	game_ui.show()
	create_server()
	add_player(multiplayer.get_unique_id())

func _on_join_button_pressed() -> void:
	error_label.text = ""

	if server_address_input.text != "":
		host = server_address_input.text

	print("Connecting to ", host)
	var error = enet_peer.create_client(host, PORT)
	if error != OK:
		_on_connected_fail(error)
		return
	
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)

func _on_connected_ok() -> void:
	print("Successfully connected to server")
	main_menu.hide()
	game_ui.show()

func _on_connected_fail(error) -> void:
	print("Connection to server failed: ", error)
	error_label.text = "Failed to connect to server: " + str(host)
	main_menu.show()
	game_ui.hide()
	multiplayer.multiplayer_peer = null

func add_player(peer_id):
	# Server chose a spawn position and tells all clients
	if isServer:
		print('Player joined ', peer_id)
		var spawn_pos = get_spawn_position()
		used_spawn_positions.append(spawn_pos)
		spawn_player.rpc(peer_id, spawn_pos)

@rpc("any_peer", "call_local")
func spawn_player(peer_id: int, spawn_pos: Vector3):
	# Add player
	var player = PlayerScene.instantiate()
	player.name = str(peer_id)
	player.position = spawn_pos
	add_child(player)
	
	# Add snowman
	var snowman = SnowmanScene.instantiate()
	snowman.position = spawn_pos
	snowman.snowman_peer_id = peer_id
	snowman.name = "Snowman" + str(peer_id)
	add_child(snowman)
	 
	if not isDedicatedServer:
		phantom_camera_3d.append_follow_targets(player)

func remove_player(peer_id):
	var player = get_player_by_peer_id(peer_id)
	if player:
		print('Player left ', peer_id)
		used_spawn_positions.erase(player.position)
		remove_child(player)
			
func get_spawn_position() -> Vector3:
	var spawns = get_tree().get_nodes_in_group("SpawnPositions")
	if spawns.is_empty():
		return Vector3(0, 4, 5)
	
	for spawn in spawns:
		if not used_spawn_positions.has(spawn.position):
			return spawn.position
	
	return spawns.pick_random().position

func start_game() -> void:
	gameStarted = true
	game_ui_bottom_label.text = "Construisez votre bonhomme de neige"
	start_game_circle.hide()
	start_game_area.set_process(false)
	
	if isServer:
		snow_spawner.start_spawning()

	for i in range(game_timer, 0, -1):
		game_ui_bottom_label.text = "Temps restant : %ds" % i
		await get_tree().create_timer(1).timeout

	end_game()

func end_game() -> void:
	gameStarted = false
	game_ui_bottom_label.text = "La partie est terminée !"
	start_game_circle.show()
	start_game_area.set_process(true)
	print("End game")

@rpc("any_peer", "call_local")
func add_snow_to_player(peer_id: int, snowflake_node_path: String) -> void:
	get_snowman_by_peer_id(peer_id).add_snow()
	delete_snowflake(snowflake_node_path)

func delete_snowflake(snowflake_node_path: String) -> void:
	var snowflake = get_node_or_null(snowflake_node_path)

	if snowflake != null:
		snowflake.queue_free()
	
func get_all_players() -> Array[Node]:
	return get_tree().get_nodes_in_group("Players")

func get_player_by_peer_id(peer_id: int) -> Player:
	return get_node_or_null(str(peer_id))

func get_snowman_by_peer_id(peer_id: int) -> Snowman:
	return get_node_or_null("Snowman" + str(peer_id))
