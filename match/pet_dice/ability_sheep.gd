class_name AbilitySheep
extends Ability

func _get_new_self() -> Resource:
	return AbilitySheep.new()

func perform_active_ability(cur_match : Match) -> bool:
	if cur_pet_dice.current_face_value == 1:
		cur_match.call_pet_constant_shaken(cur_pet_dice, true)
		return true
	
	cur_match.call_pet_shaken(cur_pet_dice)
	return false

func process_pet_action(cur_match : Match, action : Action) -> bool:
	if action.selected_pet:
		if action.selected_pet != cur_pet_dice:
			var face_index := cur_pet_dice.get_current_face_index()
			cur_pet_dice.faces[face_index] = action.selected_pet.current_face_value
			cur_match.call_pet_updated(cur_pet_dice)
			cur_match.call_pet_lurched(cur_pet_dice)
			cur_match.call_pet_shaken(action.selected_pet)
			return true
	return false
