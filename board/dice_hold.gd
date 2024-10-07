class_name DiceHold
extends Node3D

const HOVER_LIMIT := 0.8

signal interacted
signal hover_changed(is_hovering : bool)

@export var label : Label3D
@export var area : Area3D

@export var roll_player : AudioStreamPlayer

var pet_die : PetDie :
	set(value):
		pet_die = value
		if value:
			if ResourceLoader.exists(pet_die.visual_scene_path):
				var pet_die_visual_scene := load(pet_die.visual_scene_path)
				pet_die_visual = pet_die_visual_scene.instantiate()
				pet_die_visual.setup(pet_die)
				add_child(pet_die_visual)
		else:
			if pet_die_visual:
				pet_die_visual.queue_free()
				pet_die_visual = null

var pet_die_visual : PetDieVisual

var hover_timer := 0.0
var is_mouse_over := false

func _ready() -> void:
	area.input_event.connect(_on_input_event)
	area.mouse_entered.connect(_on_mouse_entered)
	area.mouse_exited.connect(_on_mouse_exited)

func _process(delta: float) -> void:
	if is_mouse_over and hover_timer <= HOVER_LIMIT:
		hover_timer += delta
		if hover_timer > HOVER_LIMIT:
			hover_changed.emit(true)

func _on_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int):
	if event.is_action_pressed("interact"):
		interacted.emit()

func _on_mouse_entered():
	is_mouse_over = true

func _on_mouse_exited():
	is_mouse_over = false
	hover_timer = 0.0
	hover_changed.emit(false)

func update():
	if pet_die_visual:
		pet_die_visual.update(pet_die)

func update_faces(face_values : Array[int]):
	if pet_die_visual:
		pet_die_visual.update_faces(face_values)

func roll_to_index(index : int):
	if pet_die_visual:
		pet_die_visual.roll_to_index(index)
	if roll_player:
		roll_player.play()

func play_lurch():
	if pet_die_visual:
		pet_die_visual.play_lurch()

func play_shake():
	if pet_die_visual:
		pet_die_visual.play_shake()

func play_ability_sfx():
	if pet_die_visual:
		pet_die_visual.play_ability_sfx()

func update_label():
	if not (label and pet_die):
		label.text = ""
		return
	
	label.text = "%s\n%s %s" % [pet_die.name, "(L)" if pet_die.is_locked else "", pet_die.current_face_value]
