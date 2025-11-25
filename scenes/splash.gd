extends Node2D

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	var viewport_size = get_viewport_rect().size
	var texture_size = sprite.texture.get_size()
	
	var scale_x = viewport_size.x / texture_size.x
	var scale_y = viewport_size.y / texture_size.y
	var scale = max(scale_x, scale_y) 
	
	sprite.position = viewport_size / 2.0
	sprite.scale = Vector2(scale, scale)
	
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://Main.tscn")
