extends Node3D

@onready var main_music: AudioStreamPlayer = $MainMusic
@onready var menu_music: AudioStreamPlayer = $MenuMusic
@onready var button_click: AudioStreamPlayer = $ButtonClick
@onready var got_snowflake: AudioStreamPlayer = $GotSnowflake
@onready var jump: AudioStreamPlayer = $Jump
@onready var win: AudioStreamPlayer = $Win
@onready var ball_bounce: AudioStreamPlayer = $BallBounce

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func play_main_music() -> void:
	main_music.play()
	return
	
func play_menu_music() -> void:
	menu_music.play()
	return

func play_button_click() -> void:
	button_click.play()
	return

func play_got_snowflake() -> void:
	got_snowflake.play()
	return

func play_jump() -> void:
	jump.play()
	return

func play_win() -> void:
	win.play()
	return

func play_ball_bounce() -> void:
	ball_bounce.play()
	return

func start_game_music() -> void:
	menu_music.stop()
	play_main_music()
