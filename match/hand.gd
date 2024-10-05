class_name Hand
extends Resource

var _pets : Array[PetDie]

var hand_index := -1

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
	pet.pet_index = _pets.size() - 1
	pet.cur_hand = self

func remove_pet(pet : PetDie):
	var index := get_index_by_pet(pet)
	if index == -1:
		return
	
	_pets.remove_at(index)
	pet.pet_index = -1
	pet.cur_hand = null

func move_pet_to_hand(pet : PetDie, hand : Hand):
	remove_pet(pet)
	hand.add_pet(pet)

func get_hand_size() -> int:
	return _pets.size()
