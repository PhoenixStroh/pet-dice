class_name PetDieVisual
extends Node3D

@export var die_type : PetDie.DICE_TYPE
@export var roll_pivot : RollPivot
@export var animation_player : AnimationPlayer
@export var number_mesh : MeshInstance3D

@export var pet_ability_player : AudioStreamPlayer
@export var pet_affected_player : AudioStreamPlayer

func setup(pet_die : PetDie):
	if pet_ability_player:
		if ResourceLoader.exists(pet_die.default_sfx_path):
			pet_ability_player.stream = load(pet_die.default_sfx_path)
	if pet_affected_player:
		if ResourceLoader.exists(pet_die.affected_sfx_path):
			pet_affected_player.stream = load(pet_die.affected_sfx_path)

func update(pet_die : PetDie):
	roll_pivot.set_dice_rotation(die_type, pet_die.get_current_face_index())
	update_faces(pet_die.faces)

func update_faces(face_values : Array[int]):
	var array := PackedInt32Array([0, 0, 0, 0, 0, 0, 0, 0])
	for i in array.size():
		if i < face_values.size():
			array[i] = face_values[i]
	number_mesh.material_override.set("shader_parameter/face_values", array)

func roll_to_index(index : int):
	if roll_pivot:
		roll_pivot.play_rotation(die_type, index)

func play_ability_sfx():
	if pet_ability_player:
		pet_ability_player.play()

func play_lurch(play_sound : bool):
	animation_player.play("lurch")
	if pet_ability_player and play_sound:
		pet_ability_player.play()

func play_shake(play_sound : bool):
	animation_player.play("shake")
	if pet_affected_player and play_sound:
		pet_affected_player.play()

func play_constant_shake():
	if animation_player.current_animation != "constant_shake":
		animation_player.play("constant_shake")

func stop_animation():
	if animation_player:
		animation_player.stop()
