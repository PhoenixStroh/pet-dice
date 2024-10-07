class_name Ability
extends Resource

@export var ability_text := "This is the default ability text."
@export var is_ability_forced := false

var cur_pet_dice : PetDie

func _get_new_self() -> Resource:
	return Ability.new()

func duplicate_fixed() -> Ability:
	var ability = _get_new_self()
	
	ability.ability_text = ability_text
	ability.cur_pet_dice = cur_pet_dice
	return ability

@warning_ignore("unused_parameter")
func perform_passive_ability(cur_match : Match):
	pass

@warning_ignore("unused_parameter")
# returns true if triggers pet action
func perform_active_ability(cur_match : Match) -> bool:
	return false

@warning_ignore("unused_parameter")
# returns true if ending pet action
func process_pet_action(cur_match : Match, action : Action) -> bool:
	return true
