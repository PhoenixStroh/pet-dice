class_name AbilityWolf
extends Ability

func _get_new_self() -> Resource:
	return AbilityWolf.new()

func perform_active_ability(cur_match : Match) -> bool:
	print("wolf ability performed")
	cur_match.get_center_hand().roll_all_pets()
	
	cur_match.call_pet_lurched(cur_pet_dice)
	
	await Utils.create_timer(2.0 + 0.1).timeout
	
	return false
