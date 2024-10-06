class_name RollPivot
extends Node3D

const ROT_UNIT := TAU / 4.0

const D6_ROTATIONS := [
	Vector3(0, 0, 0),
	Vector3(0, -180, 90),
	Vector3(0, -90, -180),
	Vector3(90, 0, 0),
	Vector3(0, -90, -90),
]

const D8_ROTATIONS := [
	Vector3(0, -90, -52.5),
	Vector3(-52.5, 180, 0),
	Vector3(-52.5, 180, 180),
	Vector3(0, 90, 52.5),
	Vector3(0, -90, 127.5),
	Vector3(52.5, 180, 180),
	Vector3(0, 90, -127.5),
]

@export var roll_time := 6.0
@export var roll_height := 4.0

func play_rotation(dice_type : PetDie.DICE_TYPE, index : int):
	var apex := get_random_rotation()
	var destination = rotation
	
	match dice_type:
		PetDie.DICE_TYPE.D4:
			pass
		PetDie.DICE_TYPE.D6:
			destination = D6_ROTATIONS[index]
		PetDie.DICE_TYPE.D8:
			destination = D8_ROTATIONS[index]
	
	position = Vector3(0, 0, 0)
	
	var pos_tween := get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	pos_tween.tween_property(self, "position", position + Vector3.UP * roll_height, roll_time * 0.5)
	pos_tween.tween_property(self, "position", Vector3(0,0,0), roll_time * 0.5).set_ease(Tween.EASE_IN)

	#var rot_tween := get_tree().create_tween()
	#rot_tween.tween_method(
		#slerp_basis.bind(quaternion, apex_quat), 0, 1, roll_time * .5
	#)
	
	var rot_tween := get_tree().create_tween()
	rot_tween.tween_property(self, "rotation_degrees", apex, roll_time * 0.5)
	rot_tween.tween_property(self, "rotation_degrees", destination, roll_time * 0.5)

func get_random_rotation() -> Vector3:
	return Vector3(get_random_rot_axis(), get_random_rot_axis(), get_random_rot_axis())


func get_random_rot_axis() -> float:
	return ROT_UNIT * float(randi() % 4)
