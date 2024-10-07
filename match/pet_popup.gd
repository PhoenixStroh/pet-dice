class_name PetPopup
extends Control

@export var pet_name_label : Label
@export var cur_value_label : Label
@export var pet_ability_label : Label
@export var d4_faces_parent : Control
@export var d4_faces : Array[Label]
@export var d6_faces_parent : Control
@export var d6_faces : Array[Label]
@export var d8_faces_parent : Control
@export var d8_faces : Array[Label]

func update(pet : PetDie):
	pet_name_label.text = pet.name
	cur_value_label.text = str(pet.current_face_value)
	if pet.ability:
		pet_ability_label.text = pet.ability.ability_text
	else:
		pet_ability_label.text = "No Ability"
	
	d4_faces_parent.visible = false
	d6_faces_parent.visible = false
	d8_faces_parent.visible = false
	var faces : Array[Label]
	match pet.type:
		PetDie.DICE_TYPE.D4:
			faces = d4_faces
			d4_faces_parent.visible = true
		PetDie.DICE_TYPE.D6:
			faces = d6_faces
			d6_faces_parent.visible = true
		PetDie.DICE_TYPE.D8:
			faces = d8_faces
			d8_faces_parent.visible = true
	
	for i in faces.size():
		var label := faces[i]
		if i < pet.faces.size():
			label.text = str(pet.faces[i])

func turn_on(pet : PetDie):
	update(pet)
	visible = true

func turn_off():
	visible = false
