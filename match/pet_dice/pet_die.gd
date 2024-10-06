class_name PetDie
extends Resource

signal rolled
signal started_pet_turn

const VALID_FACE_MIN = 1
const VALID_FACE_MAX = 8

enum DICE_TYPE {
	D4,
	D6,
	D8
}

const DICE_TYPE_SIZE := {
	DICE_TYPE.D4 : 4,
	DICE_TYPE.D6 : 5,
	DICE_TYPE.D8 : 7,
}

const DICE_TYPE_NAME := {
	DICE_TYPE.D4 : "d4",
	DICE_TYPE.D6 : "d6",
	DICE_TYPE.D8 : "d8",
}

@export var name : String = ""
@export var type : DICE_TYPE = DICE_TYPE.D6
@export var faces : Array[int] = []
@export var ability : Ability

@export_file("*.tscn") var visual_scene_path : String

var current_face_value : int :
	get():
		return faces[_current_face_index]
var _current_face_index := 0 :
	set(value):
		_current_face_index = clampi(value, 0, get_dice_size() - 1)

var is_locked := false

func setup():
	ability.cur_pet_dice = self

func duplicate_fixed() -> PetDie:
	var pet_die := PetDie.new()
	
	pet_die.name = name
	pet_die.type = type
	pet_die.faces = faces.duplicate(true)
	if ability:
		pet_die.ability = ability.duplicate_fixed()
	pet_die.visual_scene_path = visual_scene_path
	pet_die._current_face_index = _current_face_index
	pet_die.is_locked = is_locked
	
	return pet_die

func _is_faces_valid():
	if faces.size() != get_dice_size():
		push_error("Pet %s has wrong number of sides!" % name)
		return false
	
	for face in faces:
		if face < VALID_FACE_MIN or face > VALID_FACE_MAX:
			push_error("Pet Face Number is out of bounds!")
			return false
	
	return true

var cur_hand : Hand
var pet_index := -1

func get_dice_size() -> int:
	return DICE_TYPE_SIZE[type]

func get_current_face_index() -> int:
	return _current_face_index

func passive_ability():
	pass

func active_ability():
	pass

func roll(player_action := false):
	var index := randi() % get_dice_size()
	_current_face_index = index
	rolled.emit()
	
	await Utils.create_timer(2.0 + 0.1).timeout
	
	if ability and player_action:
		var is_start_pet_turn := await ability.perform_active_ability(cur_hand.cur_match)
		
		if is_start_pet_turn:
			started_pet_turn.emit()

func _to_string() -> String:
	return "%s(%s) %s%s" % [name, DICE_TYPE_NAME[type], "(L)" if is_locked else "", current_face_value]
