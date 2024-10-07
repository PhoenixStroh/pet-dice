class_name PetDieVisual
extends Node3D

@export var die_type : PetDie.DICE_TYPE
@export var roll_pivot : RollPivot
@export var animation_player : AnimationPlayer
@export var number_mesh : MeshInstance3D

func update(pet_die : PetDie):
	roll_pivot.set_dice_rotation(die_type, pet_die.get_current_face_index())

func update_faces(face_values : Array[int]):
	var array := PackedInt32Array([0, 0, 0, 0, 0, 0, 0, 0])
	for i in array.size():
		if i < face_values.size():
			array[i] = face_values[i]
	number_mesh.material_override.set("shader_parameter/face_values", array)

func roll_to_index(index : int):
	if roll_pivot:
		roll_pivot.play_rotation(die_type, index)

func play_lurch():
	animation_player.play("lurch")

func play_shake():
	animation_player.play("shake")
