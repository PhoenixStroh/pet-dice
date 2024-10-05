class_name Board
extends Node3D

# 0 : center_hand, 1 : player#1, 2 : player#2 ...
signal dice_hold_interacted(hand_index : int, pet_index : int)

@export var spacing := 2.0

@export var dice_hold_scene : PackedScene

@export var hand_pivots : Array[Node3D]

var hands_dice_holds : Array[Array] = [] # Array[Array[DiceHold]]

func _on_dice_hold_interacted(hand_index : int, pet_index : int):
	print("INTERACTED WITH HAND %s PET %s" % [hand_index, pet_index])

func _ready() -> void:
	dice_hold_interacted.connect(_on_dice_hold_interacted)

func setup(total_hands : int, center_hand : Hand):
	for i in range(total_hands):
		hands_dice_holds.append([])
	
	for i in center_hand.get_pets().size():
		var pet = center_hand.get_pets()[i]
		var dice_hold := add_pet_to_hand(0, pet)
	_space_hand(0)

func add_pet_to_hand(hand_index : int, pet_die : PetDie) -> DiceHold:
	if hand_index >= 0 and hand_index < hands_dice_holds.size():
		var pet_hold_instance : DiceHold = dice_hold_scene.instantiate()
		
		var pet_index := hands_dice_holds[hand_index].size()
		pet_hold_instance.interacted.connect(dice_hold_interacted.emit.bind(hand_index, pet_index))
		
		hands_dice_holds[hand_index].append(pet_hold_instance)
		hand_pivots[hand_index].add_child(pet_hold_instance)
		
		pet_hold_instance.set_label(pet_die.name, pet_die.current_face_value, pet_die.is_locked)
		return pet_hold_instance
	return null

func remove_pet_from_hand(hand_index : int, index : int):
	if hand_index >= 0 and hand_index < hands_dice_holds.size():
		var dice_hold = hands_dice_holds[hand_index]
		dice_hold.remove_at(index)
		dice_hold.queue_free()

func _space_hand(hand_index : int):
	var hand := hands_dice_holds[hand_index]
	for i in hand.size():
		var dice_hold = hand[i]
		dice_hold.position.x = (-hand.size()) + 1 + (2 * i)
