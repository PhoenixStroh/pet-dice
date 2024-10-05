class_name Match
extends Resource



enum MATCH_STATE {
	SETUP,
	DRAFT,
	DURING,
	END,
}

enum TURN_STATE {
	SETUP,
	TURN_ACTION,
	PET_ACTION,
	END,
}

@export var minimum_turns := 2

var match_state : MATCH_STATE = MATCH_STATE.SETUP
var turn_state : TURN_STATE = TURN_STATE.SETUP
var turn_index := 0
var turn_rolls_used := 0
var end_declared := false
var turn_index_since_declared := 0
var _player_count := 2

# 0: center, 1: player#1, 2: player#2
var _hands : Array[Hand]

#region SetGetsIfs
# 0: center, 1: player#1, 2: player#2
func get_hand(index : int) -> Hand:
	return _hands[index]

func get_center_hand() -> Hand:
	return _hands[0]

func get_cur_player_hand() -> Hand:
	return get_player_hand(get_whos_turn())

func get_player_hand(index : int) -> Hand:
	return _hands[index + 1]

func get_hands() -> Array[Hand]:
	return _hands

# 0:player#1, 1:player#2
func get_whos_turn() -> int:
	return absi(turn_index % get_player_count())

func get_player_count() -> int:
	return _player_count

func get_draft_turn_legnth() -> int:
	return get_player_count() * 2

func is_pet_in_center(pet_die : PetDie) -> bool:
	var hand = pet_die.cur_hand
	if hand:
		return hand.hand_index == 0
	push_error("is_pet_in_center did not find a current hand. something is wrong")
	return false

func is_pet_in_cur_player(pet_die : PetDie) -> bool:
	var hand = pet_die.cur_hand
	if hand:
		return (hand.hand_index - 1) == get_whos_turn()
	push_error("is_pet_in_cur_player did not find a current hand. something is wrong")
	return false

func is_pet_in_cur_player_or_center(pet_die : PetDie) -> bool:
	return is_pet_in_center(pet_die) or is_pet_in_cur_player(pet_die)

#endregion

func setup(s_starting_pets : Array[PetDie], s_player_count := 2):
	match_state = MATCH_STATE.SETUP
	turn_state = TURN_STATE.SETUP
	turn_index = 0
	end_declared = false
	_player_count = s_player_count
	
	for i in range(1 + get_player_count()):
		var hand := Hand.new()
		hand.hand_index = i
		_hands.append(hand)
	
	for s_starting_pet in s_starting_pets:
		_hands[0].add_pet(s_starting_pet)

func start_draft():
	match_state = MATCH_STATE.DRAFT

func start_during():
	match_state = MATCH_STATE.DURING
	turn_index = 1
	
	for hand in get_hands():
		for pet in hand.get_pets():
			roll_pet(pet)

func end_turn():
	turn_index += 1
	if end_declared:
		turn_index_since_declared += 1
	
	if turn_index_since_declared >= get_player_count():
		match_state = MATCH_STATE.END
		print("GAME END")
		
		var best_players : Array[Valuation]
		for i in get_player_count():
			var valuation := valuate_hand(get_player_hand(i))
			
			if best_players.size() == 0:
				best_players.append(valuation)
			else:
				var comparison := best_players[0].is_this_valuation_better(valuation)
				if comparison == valuation.COMPARISON.TIED:
					best_players.append(valuation)
				elif comparison == valuation.COMPARISON.BETTER:
					best_players.clear()
					best_players.append(valuation)
		
		if best_players.size() == 0:
			push_error("No one won? This shouldn't happen")
		if best_players.size() == 1:
			var valuation := best_players[0]
			print("Player #%s has won! They had a %s" % [valuation.player_index, valuation])
		if best_players.size() > 1:
			print("Tie for first!")
			for best_player in best_players:
				var valuation := best_player
				print("Player #%s had a %s" % [valuation.player_index, valuation])

func roll_pet(pet_die : PetDie):
	pet_die.roll()

func valuate_hand(player_hand : Hand) -> Valuation:
	var center_hand := get_center_hand()
	
	var valuation := Valuation.new()
	valuation.player_index = player_hand.hand_index - 1
	valuation.valuate_hand(player_hand, center_hand)
	
	return valuation
