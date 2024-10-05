class_name DiceHold
extends Node3D

signal interacted

@export var label : Label3D
@export var area : Area3D

func _ready() -> void:
	area.input_event.connect(_on_input_event)

func _on_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int):
	if event.is_action_pressed("interact"):
		interacted.emit()

func set_label(pet_name : String, number : int, is_locked := false):
	if label:
		label.text = "%s\n%s %s" % [pet_name, "(L)" if is_locked else "", number]

func clear_label():
	if label:
		label.text = ""
