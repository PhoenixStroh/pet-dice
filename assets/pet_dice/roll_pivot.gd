@tool
class_name RollPivot
extends Node3D

const ROT_UNIT := TAU / 4.0

@export var roll_time := 6.0
@export var roll_height := 4.0

@export var execute_rotation : bool :
	set(_value):
		play_rotation()

func play_rotation():
	var apex_quat := Quaternion.from_euler(get_random_rotation())
	var destination_quat := Quaternion.from_euler(get_random_rotation())
	
	position = Vector3(0, 0, 0)
	
	var pos_tween := get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	pos_tween.tween_property(self, "position", position + Vector3.UP * roll_height, roll_time * 0.5)
	pos_tween.tween_property(self, "position", Vector3(0,0,0), roll_time * 0.5).set_ease(Tween.EASE_IN)

	#var rot_tween := get_tree().create_tween()
	#rot_tween.tween_method(
		#slerp_basis.bind(quaternion, apex_quat), 0, 1, roll_time * .5
	#)
	
	var rot_tween := get_tree().create_tween()
	rot_tween.tween_property(self, "quaternion", apex_quat, roll_time * 0.5)
	rot_tween.tween_property(self, "quaternion", destination_quat, roll_time * 0.5)

#func slerp_basis(weight: float, start: Basis, end: Basis):
	#print(start.slerp(end, weight))

func get_random_rotation() -> Vector3:
	return Vector3(
		get_random_rot_axis(), 
		get_random_rot_axis(), 
		get_random_rot_axis()
	)

func get_random_rot_axis() -> float:
	return ROT_UNIT * float(randi() % 4)
