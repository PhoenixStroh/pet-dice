class_name BoardHand
extends Node3D

signal dice_hold_interacted(pet_die : PetDie)

var spacing := 2.0

var dice_hold_scene : PackedScene

var hand_index = 0

var dice_holds : Array[DiceHold]

func setup(s_dice_hold_scene : PackedScene, s_hand_index := 0):
	dice_hold_scene = s_dice_hold_scene
	hand_index = s_hand_index

func get_dice_hold(pet_die : PetDie) -> DiceHold:
	for dice_hold in dice_holds:
		if dice_hold.pet_die == pet_die:
			return dice_hold
	return null

func add_pet(pet_die : PetDie) -> DiceHold:
	var dice_hold_instance : DiceHold = dice_hold_scene.instantiate()
	dice_hold_instance.pet_die = pet_die
	
	dice_hold_instance.interacted.connect(dice_hold_interacted.emit.bind(pet_die))
	
	dice_holds.append(dice_hold_instance)
	add_child(dice_hold_instance)
	
	dice_hold_instance.update_label()
	
	space_hand()
	return dice_hold_instance

func remove_pet(pet_die : PetDie):
	for dice_hold in dice_holds:
		if dice_hold.pet_die == pet_die:
			dice_holds.erase(dice_hold)
			dice_hold.queue_free()
	space_hand()

func space_hand():
	for i in dice_holds.size():
		var dice_hold = dice_holds[i]
		dice_hold.position.x = (-dice_holds.size()) + 1 + (spacing * i)
