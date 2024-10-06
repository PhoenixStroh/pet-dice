class_name AbilityMouse
extends Ability

const MAX_TOTAL := 6

func _get_new_self() -> Resource:
	return AbilityMouse.new()

@warning_ignore("unused_parameter")
func perform_passive_ability(cur_match : Match):
	var total := 0
	for pet in cur_pet_dice.cur_hand.get_pets():
		total += pet.current_face_value
	
	if total < MAX_TOTAL:
		cur_pet_dice.cur_hand.additional_turn_rolls_allowed += 1
