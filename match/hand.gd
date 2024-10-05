class_name Hand
extends Resource

var _pets : Array[PetDie]

func get_pet(pet : PetDie) -> PetDie:
	if _pets.has(pet):
		return _pets[pet]
	return null

func get_pet_by_index(index : int) -> PetDie:
	if index >= 0 and index < get_hand_size():
		return _pets[index]
	return null

func get_index_by_pet(pet : PetDie) -> int:
	return _pets.find(pet)

func get_pets() -> Array[PetDie]:
	return _pets

func add_pet(pet : PetDie):
	_pets.append(pet)

func remove_pet(pet : PetDie):
	var index := get_index_by_pet(pet)
	if index == -1:
		return
	
	_pets.remove_at(index)

func get_hand_size() -> int:
	return _pets.size()
