class_name Valuation
extends Resource

enum COMPARISON {
	BETTER = 1,
	TIED = 0,
	WORSE = -1,
}

enum HAND_PATTERN {
	HIGHEST_NUMBER,
	PAIR,
	RUN,
	THREE_KIND,
}

const HAND_PATTERN_NAME := {
	HAND_PATTERN.HIGHEST_NUMBER : "Highest Number",
	HAND_PATTERN.PAIR : "Pair",
	HAND_PATTERN.RUN : "Run",
	HAND_PATTERN.THREE_KIND : "Three of a Kind",
}

var hand_pattern : HAND_PATTERN
var hand_value : int = 0

var player_index := -1

func valuate_hand(player_hand : Hand, center_hand : Hand):
	var total_pets : Array[PetDie]
	
	total_pets.append_array(player_hand.get_pets())
	total_pets.append_array(center_hand.get_pets())
	
	var highest_value := 0
	
	# check for three of a kind
	for i in range(1,8):
		var count := 0
		for pet in total_pets:
			if pet.current_face_value == i:
				count += 1
		if count > 2:
			highest_value = i
	if highest_value > 0:
		hand_pattern = HAND_PATTERN.THREE_KIND
		hand_value = highest_value
		return
		
	highest_value = 0
	# check for a run
	for i in range(1,6):
		var values_found := [false, false, false]
		for pet in total_pets:
			values_found[0] = pet.current_face_value == i or values_found[0]
			values_found[1] = pet.current_face_value == i + 1 or values_found[1]
			values_found[2] = pet.current_face_value == i + 2 or values_found[2]
		
		if values_found[0] and values_found[1] and values_found[2]:
			highest_value = i
	if highest_value > 0:
		hand_pattern = HAND_PATTERN.RUN
		hand_value = highest_value
		return
	
	highest_value = 0
	# check for a pair
	for i in range(1,8):
		var count := 0
		for pet in total_pets:
			if pet.current_face_value == i:
				count += 1
		if count > 1:
			highest_value = i
	if highest_value > 0:
		hand_pattern = HAND_PATTERN.PAIR
		hand_value = highest_value
		return
	
	highest_value = 0
	for pet in total_pets:
		highest_value = max(highest_value, pet.current_face_value)
	
	hand_pattern = HAND_PATTERN.HIGHEST_NUMBER
	hand_value = highest_value
	return

# -1 worse, 0 tied, 1 better
func is_this_valuation_better(other_valuation : Valuation) -> COMPARISON:
	if hand_pattern != other_valuation.hand_pattern:
		var is_better_pattern := hand_pattern > other_valuation.hand_pattern
		return COMPARISON.BETTER if is_better_pattern else COMPARISON.WORSE
	
	if hand_value == other_valuation.hand_value:
		return COMPARISON.TIED
	var is_better_value := hand_value > other_valuation.hand_value
	return COMPARISON.BETTER if is_better_value else COMPARISON.WORSE

func _to_string() -> String:
	return "%s %s" % [HAND_PATTERN_NAME[hand_pattern], hand_value]
