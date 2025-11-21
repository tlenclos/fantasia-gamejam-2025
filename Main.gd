class_name Main extends Node3D

const PlayerScene = preload("res://scenes/Player.tscn")
const SnowmanScene = preload("res://scenes/Snowman.tscn")

const PORT = 9999
var enet_peer = ENetMultiplayerPeer.new()
var host = "localhost"
var isDedicatedServer = OS.has_feature("dedicated_server")
var gameStarted = false
var isServer = false

@export var game_timer: int = 3
@onready var main_menu: PanelContainer = $MenuGroup/MainMenu
@onready var game_ui: CanvasLayer = $GameUIGroup
@onready var game_ui_bottom_label: Label = $GameUIGroup/GameUI/MarginContainer/VBoxContainer/Label
@onready var server_address_input: LineEdit = $MenuGroup/MainMenu/MarginContainer/VBoxContainer/ServerAddressInput
@onready var error_label: Label = $MenuGroup/MainMenu/MarginContainer/VBoxContainer/ErrorLabel
@onready var phantom_camera_3d: PhantomCamera3D = $PhantomCamera3D
@onready var start_game_circle: MeshInstance3D = $StartGameCircle
@onready var start_game_area: Area3D = $StartGameCircle/StartGameArea
@onready var snow_spawner: SnowSpaner = $SnowSpawner

const playersColor = [
	Color(0.672, 0.0, 0.0, 1.0),
	Color(0.598, 0.932, 0.953, 1.0),
	Color(0.186, 0.169, 0.867, 1.0),
	Color(0.86, 0.434, 0.368, 1.0),
	Color(0.32, 0.847, 0.185, 1.0),
	Color(0.814, 0.758, 0.054, 1.0),
]

func _ready() -> void:
	if isDedicatedServer:
		print("Starting dedicated server on port ", PORT)
		create_server()

func _physics_process(_delta: float) -> void:
	var all_players = get_all_players()
	if not gameStarted and all_players.size() > 0 and start_game_area != null and start_game_area.get_overlapping_bodies().filter(func(body): return body is Player).size() == all_players.size():
		start_game()

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
		var spawn = get_spawn_position()

		if spawn == null:
			# @TODO Kick player : no more space
			return

		var color = get_player_color()

		spawn.set_meta("player", peer_id)
		spawn_player.rpc(peer_id, spawn.get_path(), color)

@rpc("any_peer", "call_local")
func spawn_player(peer_id: int, spawn_path: String, color: Color):
	var spawn = get_node(spawn_path)

	# Add player
	var player = PlayerScene.instantiate()
	player.name = str(peer_id)
	player.position = spawn.position
	player.set_meta("spawn_path", spawn_path)
	add_child(player)

	# Add snowman
	var snowman = SnowmanScene.instantiate()
	snowman.position = spawn.position
	snowman.player = player
	snowman.name = "Snowman" + str(peer_id)
	add_child(snowman)

	player.set_color(color)

	if not isDedicatedServer:
		phantom_camera_3d.append_follow_targets(player)

func remove_player(peer_id):
	var player = get_player_by_peer_id(peer_id)
	if player:
		print('Player left ', peer_id)
		var spawn_path = player.get_meta("spawn_path", "")
		var spawn = get_node_or_null(spawn_path)

		if spawn != null:
			spawn.set_meta("player", null)

		remove_child(player)

func get_player_color() -> Color:
	var players = get_all_players();
	var available_colors = [];

	for color in playersColor:
		var has_color = false

		for player in players:
			if player.color == color:
				has_color = true
				break;

		if not has_color:
			available_colors.append(color)

	return available_colors.pick_random()

func get_spawn_position() -> Node:
	var spawns = get_tree().get_nodes_in_group("SpawnPositions")
	if spawns.is_empty():
		return null

	var free_spawn = [];

	for spawn in spawns:
		if spawn.get_meta("player") == null:
			free_spawn.append(spawn)

	if free_spawn.size() == 0:
		return null

	return free_spawn.pick_random()

func start_game() -> void:
	gameStarted = true
	game_ui_bottom_label.text = "Construisez votre bonhomme de neige"
	start_game_circle.hide()
	start_game_area.set_process(false)

	# Reset all snowmans
	for player in get_all_players():
		get_snowman_by_peer_id(int(player.name)).reset()

	for i in range(game_timer, 0, -1):
		game_ui_bottom_label.text = "Démarrage dans : %ds" % i
		await get_tree().create_timer(1).timeout

	game_ui.hide();

	if isServer:
		snow_spawner.start_spawning()

func end_game() -> void:
	gameStarted = false
	game_ui.show()
	game_ui_bottom_label.text = "La partie est terminée !"
	start_game_circle.show()
	start_game_area.set_process(true)

	if isServer:
		snow_spawner.stop_spawning()

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

@rpc("any_peer", "call_local")
func win_game(player: Player) -> void:
	end_game()
