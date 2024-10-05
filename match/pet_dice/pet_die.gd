class_name PetDie
extends Resource

const VALID_FACE_MIN = 0
const VALID_FACE_MAX = 8

enum DICE_TYPE {
	D4,
	D6,
	D8
}

const DICE_TYPE_SIZE := {
	DICE_TYPE.D4 : 3,
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
@export var ability_text := "This is the default ability text."

var current_face_value : int :
	get():
		return faces[_current_face_index]
var _current_face_index := 0 :
	set(value):
		_current_face_index = clampi(value, 0, get_dice_size() - 1)
var is_locked := false

func _is_faces_valid():
	if faces.size() != get_dice_size():
		push_error("Pet %s has wrong number of sides!" % name)
		return false
	
	for face in faces:
		if face < VALID_FACE_MIN or face > VALID_FACE_MAX:
			push_error("Pet Face Number is out of bounds!")
			return false
	
	return true

func get_dice_size() -> int:
	return DICE_TYPE_SIZE[type]

func passive_ability():
	pass

func active_ability():
	pass

func get_rolled_value() -> int:
	var index := randi() % get_dice_size()
	return faces[index]

func _to_string() -> String:
	return "%s(%s) %s%s" % [name, DICE_TYPE_NAME[type], "(L)" if is_locked else "", current_face_value]
