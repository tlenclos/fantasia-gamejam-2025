extends Button

# Bouncy button from an example here https://qaqelol.itch.io/tweens

var tween: Tween

func _ready():
	pivot_offset = size * Vector2(0.9, 0.9)
	
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)

func _on_button_down():
	if tween: tween.kill()
	scale = Vector2(0.9, 0.9)

func _on_button_up():
	tween = create_tween().set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_SPRING)
	tween.tween_property(self, "scale", Vector2(1,1), 0.25)
