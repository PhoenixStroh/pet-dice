class_name Match
extends Resource

signal pet_die_rolled(pet_die : PetDie)
signal pet_die_moved_to_hand(pet_die : PetDie, hand : Hand)
signal pet_die_updated(pet_die : PetDie)
signal pet_die_lurched(pet_die : PetDie, play_sound : bool)
signal pet_die_abilitied(pet_die : PetDie)
signal pet_die_shaken(pet_die : PetDie, play_sound : bool)
signal pet_die_constant_shaken(pet_die : PetDie, is_shaking : bool)
signal pet_die_started_pet_turn(pet : PetDie)

signal input_frozen_changed(new_is_frozen : bool)
signal turn_state_changed(new_turn_state : TURN_STATE)

signal game_ended(winner_indexes : Array[Valuation], valuations : Array[Valuation])

enum MATCH_STATE {
	SETUP,
	DRAFT,
	DURING,
	END,
}

enum TURN_STATE {
	TURN_ACTION,
	PET_ACTION,
}

@export var minimum_turns := 2

var match_state : MATCH_STATE = MATCH_STATE.SETUP
var turn_state : TURN_STATE = TURN_STATE.TURN_ACTION :
	set(value):
		turn_state = value
		turn_state_changed.emit(turn_state)
var is_input_frozen := false :
	set(value):
		is_input_frozen = value
		input_frozen_changed.emit(is_input_frozen)
var turn_index := 0
var turn_rolls_used := 0
var end_declared := false
var turn_index_since_declared := 0
var _player_count := 2

var has_rolled_this_turn := false

var cur_pet_dice : PetDie

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

func get_cur_ability() -> Ability:
	return cur_pet_dice.ability

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

func get_rolls_remaining() -> int:
	var cur_hand := get_cur_player_hand()
	return maxi(cur_hand.turn_rolls_allowed + cur_hand.additional_turn_rolls_allowed - turn_rolls_used, 0)

func can_take_turn_roll() -> bool:
	var cur_hand := get_cur_player_hand()
	return turn_rolls_used < cur_hand.turn_rolls_allowed + cur_hand.additional_turn_rolls_allowed

#endregion

func _on_pet_die_started_pet_turn(pet_die : PetDie):
	start_pet_turn(pet_die)
	pet_die_started_pet_turn.emit()

func setup(s_starting_pets : Array[PetDie], s_player_count := 2):
	match_state = MATCH_STATE.SETUP
	turn_state = TURN_STATE.TURN_ACTION
	turn_index = 0
	end_declared = false
	_player_count = s_player_count
	
	for i in range(1 + get_player_count()):
		var hand := Hand.new()
		hand.pet_die_moved_to.connect(pet_die_moved_to_hand.emit.bind(hand))
		hand.hand_index = i
		hand.cur_match = self
		_hands.append(hand)
		
		hand.pet_die_rolled.connect(pet_die_rolled.emit)
		hand.pet_die_started_pet_turn.connect(_on_pet_die_started_pet_turn)
	
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

func start_pet_turn(pet_die : PetDie):
	turn_state = TURN_STATE.PET_ACTION
	if pet_die.ability:
		cur_pet_dice = pet_die

func end_pet_turn():
	turn_state = TURN_STATE.TURN_ACTION
	call_pet_constant_shaken(cur_pet_dice, false)
	cur_pet_dice = null

func end_turn():
	for pet in get_cur_player_hand().get_pets():
		pet.is_locked = false
	
	turn_index += 1
	turn_rolls_used = 0
	has_rolled_this_turn = false
	
	if end_declared:
		turn_index_since_declared += 1
	
	update_passives()
	
	if turn_index_since_declared >= get_player_count():
		match_state = MATCH_STATE.END
		
		var best_players : Array[Valuation]
		var valuations : Array[Valuation]
		for i in get_player_count():
			var valuation := valuate_hand(get_player_hand(i))
			valuations.append(valuation)
			
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
		
		game_ended.emit(best_players, valuations)

func roll_pet(pet_die : PetDie, player_action := false):
	if player_action:
		turn_rolls_used += 1
		has_rolled_this_turn = true
	await pet_die.roll(player_action)

func call_pet_updated(pet_die : PetDie):
	pet_die_updated.emit(pet_die)

func call_pet_lurched(pet_die : PetDie, play_sound := true):
	pet_die_lurched.emit(pet_die)

func call_pet_shaken(pet_die : PetDie, play_sound := true):
	pet_die_shaken.emit(pet_die)

func call_pet_abilitied(pet_die : PetDie):
	pet_die_abilitied.emit(pet_die)

func call_pet_constant_shaken(pet_die : PetDie, is_shaking : bool):
	pet_die_constant_shaken.emit(pet_die, is_shaking)

func update_passives():
	for hand in get_hands():
		hand.additional_turn_rolls_allowed = 0
	
	for hand in get_hands():
		for pet in hand.get_pets():
			if pet.ability:
				pet.ability.perform_passive_ability(self)

func valuate_hand(player_hand : Hand) -> Valuation:
	var center_hand := get_center_hand()
	
	var valuation := Valuation.new()
	valuation.player_index = player_hand.hand_index - 1
	valuation.valuate_hand(player_hand, center_hand)
	
	return valuation
