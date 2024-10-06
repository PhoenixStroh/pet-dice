class_name AbilityWolf
extends Ability

func _get_new_self() -> Resource:
	return AbilityWolf.new()

func perform_active_ability(cur_match : Match) -> bool:
	print("wolf ability performed")
	cur_match.get_center_hand().roll_all_pets()
	return false
