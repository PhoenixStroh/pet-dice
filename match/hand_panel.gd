extends Control

@export var open_close_button : Button

var init_pos : Vector2

var is_open := false

func _ready() -> void:
	if open_close_button:
		open_close_button.pressed.connect(_on_open_close_button_pressed)
	
	init_pos = position

func _process(delta: float) -> void:
	if is_open:
		position.x = lerp(position.x, 0.0, 0.3)
	else:
		position.x = lerp(position.x, init_pos.x, 0.3)

func _on_open_close_button_pressed():
	if is_open:
		is_open = false
	else:
		is_open = true
