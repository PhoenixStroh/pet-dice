extends AudioStreamPlayer

func _ready() -> void:
	var parent := get_parent()
	if parent and parent is Button:
		parent.pressed.connect(_on_button_pressed)

func _on_button_pressed():
	play()
