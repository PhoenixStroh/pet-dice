class_name Hand
extends Resource

signal pet_die_rolled(pet : PetDie)
signal pet_die_started_pet_turn(pet : PetDie)

var _pets : Array[PetDie]

var turn_rolls_allowed := 1
var additional_turn_rolls_allowed := 0

var cur_match : Match
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
	
	pet.rolled.connect(pet_die_rolled.emit.bind(pet))
	pet.started_pet_turn.connect(pet_die_started_pet_turn.emit.bind(pet))

func remove_pet(pet : PetDie):
	var index := get_index_by_pet(pet)
	if index == -1:
		return
	
	_pets.remove_at(index)
	pet.pet_index = -1
	pet.cur_hand = null
	
	pet.rolled.disconnect(pet_die_rolled.emit)
	pet.started_pet_turn.disconnect(pet_die_started_pet_turn.emit)

func move_pet_to_hand(pet : PetDie, hand : Hand):
	remove_pet(pet)
	hand.add_pet(pet)

func roll_all_pets():
	for pet in get_pets():
		pet.roll()

func get_hand_size() -> int:
	return _pets.size()
