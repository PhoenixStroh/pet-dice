class_name AbilitySpider
extends Ability

func _get_new_self() -> Resource:
	return AbilitySpider.new()

func perform_active_ability(cur_match : Match) -> bool:
	cur_match.call_pet_constant_shaken(cur_pet_dice, true)
	return true

func process_pet_action(cur_match : Match, action : Action) -> bool:
	if action.selected_pet:
		if not action.selected_pet.is_locked:
			if not action.selected_pet.cur_hand == cur_match.get_cur_player_hand():
				if not action.selected_pet.cur_hand == cur_match.get_center_hand():
					action.selected_pet.is_locked = true
					cur_match.call_pet_lurched(cur_pet_dice)
					cur_match.call_pet_shaken(action.selected_pet)
					return true
	return false
