class_name AbilityElephant
extends Ability

const MAX_TOTAL := 6

func _get_new_self() -> Resource:
	return AbilityElephant.new()

@warning_ignore("unused_parameter")
func perform_passive_ability(cur_match : Match):
	var total := 0
	for hand in cur_match.get_hands():
		if hand != cur_match.get_cur_player_hand():
			if hand != cur_match.get_center_hand():
				for pet in hand.get_pets():
					total += pet.current_face_value
	
	if total > MAX_TOTAL:
		cur_pet_dice.cur_hand.additional_turn_rolls_allowed += 1
