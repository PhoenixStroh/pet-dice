class_name AbilityMagpie
extends Ability

func _get_new_self() -> Resource:
	return AbilityMagpie.new()

func perform_active_ability(cur_match : Match) -> bool:
	cur_match.call_pet_constant_shaken(cur_pet_dice, true)
	return true

func process_pet_action(cur_match : Match, action : Action) -> bool:
	if action.selected_pet:
		if not action.selected_pet.is_locked:
			if not action.selected_pet.cur_hand == cur_match.get_cur_player_hand():
				if not action.selected_pet.cur_hand == cur_match.get_center_hand():
					var cur_hand := cur_pet_dice.cur_hand
					var other_hand := action.selected_pet.cur_hand
					
					cur_hand.move_pet_to_hand(cur_pet_dice, other_hand)
					cur_hand.move_pet_to_hand(action.selected_pet, cur_hand)
					
					cur_match.call_pet_updated(action.selected_pet)
					
					cur_match.call_pet_abilitied(cur_pet_dice)
					cur_match.call_pet_shaken(cur_pet_dice, false)
					cur_match.call_pet_shaken(action.selected_pet)
					
					return true
	return false
