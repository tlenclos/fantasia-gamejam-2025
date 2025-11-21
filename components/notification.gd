class_name Notification extends Control

@onready var label: Label = $Label

## Debug
#func _ready():
#	toast("Coucou")

func toast(text: String):
	label.text = text
	self.visible = true
	_start_tween_effect()

func _start_tween_effect():
		var tween = get_tree().create_tween()
		tween.tween_property(label, "modulate", Color.CORAL, 1.0)
		tween.tween_property(label, "scale", Vector2(), 2.0)
		tween.tween_callback(func(): self.visible = false)
	
