class_name AbilityArmadillo
extends Ability

func _get_new_self() -> Resource:
	return AbilityArmadillo.new()

func perform_active_ability(cur_match : Match) -> bool:
	if cur_pet_dice.current_face_value == 2:
		cur_match.call_pet_shaken(cur_pet_dice)
		return false
	
	cur_match.call_pet_constant_shaken(cur_pet_dice, true)
	return true

func process_pet_action(cur_match : Match, action : Action) -> bool:
	if action.selected_pet == cur_pet_dice:
		cur_match.call_pet_constant_shaken(cur_pet_dice, false)
		await cur_pet_dice.roll()
		
		if cur_pet_dice.current_face_value == 2:
			cur_match.call_pet_shaken(cur_pet_dice)
			return true
		else:
			cur_match.call_pet_constant_shaken(cur_pet_dice, true)
			cur_match.call_pet_abilitied(cur_pet_dice)
	return false
