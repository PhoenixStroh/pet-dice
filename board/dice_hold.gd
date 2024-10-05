class_name DiceHold
extends Node3D

signal interacted

@export var label : Label3D
@export var area : Area3D

var pet_die : PetDie

func _ready() -> void:
	area.input_event.connect(_on_input_event)

func _on_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int):
	if event.is_action_pressed("interact"):
		interacted.emit()

func update_label():
	if not (label and pet_die):
		label.text = ""
		return
	
	label.text = "%s\n%s %s" % [pet_die.name, "(L)" if pet_die.is_locked else "", pet_die.current_face_value]
