class_name DiceHold
extends Node3D

signal interacted

@export var label : Label3D
@export var area : Area3D

var pet_die : PetDie :
	set(value):
		pet_die = value
		if value:
			if ResourceLoader.exists(pet_die.visual_scene_path):
				var pet_die_visual_scene := load(pet_die.visual_scene_path)
				pet_die_visual = pet_die_visual_scene.instantiate()
				add_child(pet_die_visual)
		else:
			if pet_die_visual:
				pet_die_visual.queue_free()
				pet_die_visual = null

var pet_die_visual : PetDieVisual

func _ready() -> void:
	area.input_event.connect(_on_input_event)

func _on_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int):
	if event.is_action_pressed("interact"):
		interacted.emit()

func update():
	if pet_die_visual:
		pet_die_visual.update(pet_die)

func update_faces(face_values : Array[int]):
	if pet_die_visual:
		pet_die_visual.update_faces(face_values)

func roll_to_index(index : int):
	if pet_die_visual:
		pet_die_visual.roll_to_index(index)

func play_lurch():
	if pet_die_visual:
		pet_die_visual.play_lurch()

func play_shake():
	if pet_die_visual:
		pet_die_visual.play_shake()

func update_label():
	if not (label and pet_die):
		label.text = ""
		return
	
	label.text = "%s\n%s %s" % [pet_die.name, "(L)" if pet_die.is_locked else "", pet_die.current_face_value]
