class_name PetButtonListener
extends GridContainer

@export var continue_button : Button

var selected_pets : Array[PetDie]

func _ready() -> void:
	for child in get_children():
		if child is Button:
			child.pressed.connect(_on_button_pressed.bind(child))

func _on_button_pressed(button : Button):
	button.disabled = true
	
	var pet_die = button.get_meta("pet")
	if pet_die and pet_die is PetDie:
		selected_pets.append(pet_die)
		if selected_pets.size() >= 6:
			for child in get_children():
				if child is Button:
					child.disabled = true
			if continue_button:
				continue_button.disabled = false
