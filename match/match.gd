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
var end_declared := false
var _player_count := 2

# 0: center, 1: player#1, 2: player#2
var _hands : Array[Hand]

#region SetGets
# 0: center, 1: player#1, 2: player#2
func get_hand(index : int) -> Hand:
	return _hands[index]

func get_center_hand() -> Hand:
	return _hands[0]

func get_player_hands(index : int) -> Hand:
	return _hands[index + 1]

func get_hands() -> Array[Hand]:
	return _hands

# 0:player#1, 1:player#2
func get_whos_turn() -> int:
	return absi(turn_index % _player_count)
#endregion

func setup(s_starting_pets : Array[PetDie], s_player_count := 2):
	match_state = MATCH_STATE.SETUP
	turn_state = TURN_STATE.SETUP
	turn_index = 0
	end_declared = false
	_player_count = s_player_count
	
	for i in range(1 + _player_count):
		_hands.append(Hand.new())
	
	for s_starting_pet in s_starting_pets:
		_hands[0].add_pet(s_starting_pet)

func start_draft():
	match_state = MATCH_STATE.DRAFT

func start_during():
	match_state = MATCH_STATE.DURING
	turn_index = 0

func end_turn():
	turn_index += 1
