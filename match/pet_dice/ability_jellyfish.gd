class_name AbilityJellyfish
extends Ability

func _get_new_self() -> Resource:
	return AbilityJellyfish.new()

func perform_active_ability(cur_match : Match) -> bool:
	if cur_pet_dice.current_face_value == 1:
		cur_match.call_pet_shaken(cur_pet_dice)
		return false
	return true

func process_pet_action(cur_match : Match, action : Action) -> bool:
	if action.selected_pet:
		if not action.selected_pet.is_locked:
			if not action.selected_pet.cur_hand == cur_match.get_cur_player_hand():
				if not action.selected_pet.cur_hand == cur_match.get_center_hand():
					action.selected_pet.roll()
					cur_match.call_pet_shaken(action.selected_pet)
					return true
	return false
