class_name Board
extends Node3D

signal pet_die_interacted(pet_die : PetDie)

@export var spacing := 2.0

@export var dice_hold_scene : PackedScene

@export var board_hands : Array[BoardHand]

func setup(center_hand : Hand):
	for i in board_hands.size():
		var board_hand = board_hands[i]
		board_hand.setup(dice_hold_scene, i)
		board_hand.dice_hold_interacted.connect(pet_die_interacted.emit)
		
		board_hands.append(board_hand)
	
	for i in center_hand.get_pets().size():
		var pet = center_hand.get_pets()[i]
		add_pet_to_hand(0, pet)

func get_board_hand_of_pet(pet_die : PetDie) -> BoardHand:
	for board_hand in board_hands:
		if board_hand.get_dice_hold(pet_die):
			return board_hand
	return null

func add_pet_to_hand(hand_index : int, pet_die : PetDie) -> DiceHold:
	if hand_index >= 0 and hand_index < board_hands.size():
		return board_hands[hand_index].add_pet(pet_die)
	return null

func remove_pet(pet_die : PetDie):
	for board_hand in board_hands:
		if board_hand.get_dice_hold(pet_die):
			board_hand.remove_pet(pet_die)

func move_pet_to_hand(hand_index : int, pet_die : PetDie):
	remove_pet(pet_die)
	add_pet_to_hand(hand_index, pet_die)

func roll_pet_visually(pet_die : PetDie):
	for board_hand in board_hands:
		var dice_hold := board_hand.get_dice_hold(pet_die)
		if dice_hold:
			dice_hold.update_label()
