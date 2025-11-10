extends Node3D

const PORT = 9999
const Player = preload("res://Player.tscn")
var enet_peer = ENetMultiplayerPeer.new()
var spawn_position = Vector3(0, 4, 5)

@onready var main_menu: PanelContainer = $CanvasLayer/MainMenu
@onready var server_address_input: LineEdit = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/ServerAddressInput

func _on_host_button_pressed() -> void:
	main_menu.hide()

	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	# multiplayer.peer_connected.disconnect(remove_player)

	add_player(multiplayer.get_unique_id())

func _on_join_button_pressed() -> void:
	main_menu.hide()
	var host = "localhost"
	if server_address_input.text != "":
		host = server_address_input.text

	print("Connected to ", host)
	enet_peer.create_client(server_address_input.text, PORT)
	multiplayer.multiplayer_peer = enet_peer

func add_player(peer_id):
	var player = Player.instantiate()
	player.name = str(peer_id)
	player.position = spawn_position
	add_child(player)

#func remove_player(peer_id):
	#for player_peer_id in players:
		#if player_peer_id == str(peer_id):
			#remove_child(players[player_peer_id])
			#players.erase(str(player_peer_id))
