class_name Board
extends Node3D

signal pet_die_interacted(pet_die : PetDie)

@export var spacing := 2.0

@export var dice_hold_scene : PackedScene

@export var board_hands : Array[BoardHand]

@export var pet_popup : PetPopup

func _on_pet_dice_hover_changed(is_hovering : bool, pet_die : PetDie):
	if pet_popup:
		if is_hovering and pet_die:
			pet_popup.turn_on(pet_die)
		else:
			pet_popup.turn_off()

func setup(center_hand : Hand):
	for i in board_hands.size():
		var board_hand = board_hands[i]
		board_hand.setup(dice_hold_scene, i)
		board_hand.dice_hold_interacted.connect(pet_die_interacted.emit)
		board_hand.pet_dice_hover_changed.connect(_on_pet_dice_hover_changed)
		
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

func update_pet(pet_die : PetDie):
	for board_hand in board_hands:
		if board_hand.get_dice_hold(pet_die):
			board_hand.get_dice_hold(pet_die).update()

func update_pet_faces(pet_die : PetDie, face_values : Array[int]):
	for board_hand in board_hands:
		if board_hand.get_dice_hold(pet_die):
			board_hand.get_dice_hold(pet_die).update_faces(face_values)

func roll_pet_to_index(pet_die : PetDie):
	for board_hand in board_hands:
		var dice_hold := board_hand.get_dice_hold(pet_die)
		if dice_hold:
			dice_hold.roll_to_index(pet_die.get_current_face_index())

func lurch_pet(pet_die : PetDie):
	for board_hand in board_hands:
		var dice_hold := board_hand.get_dice_hold(pet_die)
		if dice_hold:
			dice_hold.play_lurch()

func shake_pet(pet_die : PetDie):
	for board_hand in board_hands:
		var dice_hold := board_hand.get_dice_hold(pet_die)
		if dice_hold:
			dice_hold.play_shake()
