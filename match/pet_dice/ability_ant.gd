class_name AbilityAnt
extends Ability

func _get_new_self() -> Resource:
	return AbilityAnt.new()

func perform_active_ability(cur_match : Match) -> bool:
	var highest_pets : Array[PetDie]
	for hand in cur_match.get_hands():
		for pet in hand.get_pets():
			if highest_pets.size() == 0:
				highest_pets.append(pet)
			elif pet.current_face_value == highest_pets[0].current_face_value:
				highest_pets.append(pet)
			elif pet.current_face_value > highest_pets[0].current_face_value:
				highest_pets.clear()
				highest_pets.append(pet)
	
	for highest_pet in highest_pets:
		highest_pet.set_current_face(0)
		cur_match.call_pet_shaken(highest_pet)
		cur_match.call_pet_updated(highest_pet)
	
	return false
