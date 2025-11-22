class_name Notification extends Control

@onready var label: Label = $Label
var tween: Tween

func toast(text: String, time: float = 1.0):
	label.text = text
	self.visible = true
	label.modulate = Color.BLACK
	label.scale = Vector2.ONE

	if tween:
		tween.kill()
	tween = get_tree().create_tween()
	tween.tween_property(label, "modulate", Color.CORAL, time)
	tween.tween_property(label, "scale", Vector2(), time)
	tween.tween_callback(func(): self.visible = false)
