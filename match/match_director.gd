class_name MatchDirector
extends Node

@export var starting_pets : Array[PetDie]

@export var board : Board
@export var end_turn_button : Button
@export var declare_end_button : Button

var cur_match : Match

func _ready() -> void:
	board.pet_die_interacted.connect(_on_pet_die_interacted)
	
	end_turn_button.pressed.connect(_on_end_turn_button_pressed)
	declare_end_button.pressed.connect(_on_declare_end_button_pressed)
	
	for i in starting_pets.size():
		var starting_pet := starting_pets[i]
		starting_pets[i] = starting_pet.duplicate_fixed()
		starting_pets[i].setup()
	
	setup()

func _on_end_turn_button_pressed():
	var action := Action.new()
	action.ending_turn = true
	process_action(action)

func _on_declare_end_button_pressed():
	var action := Action.new()
	action.declared_end = true
	process_action(action)

func _on_pet_die_interacted(pet_die : PetDie):
	var action = Action.new()
	action.selected_pet = pet_die
	process_action(action)

func _on_pet_die_rolled(pet_die : PetDie):
	print("rolled ", pet_die)
	board.roll_pet_to_index(pet_die)

func _input(event: InputEvent) -> void:
	if OS.has_feature("debug"):
		if event.is_action_pressed("restart"):
			get_tree().reload_current_scene()

func setup():
	cur_match = Match.new()
	cur_match.pet_die_rolled.connect(_on_pet_die_rolled)
	
	# Setup
	cur_match.setup(starting_pets)
	board.setup(cur_match.get_center_hand())
	
	cur_match.start_draft()

func process_action(action : Action):
	# Draft Actions
	match cur_match.match_state:
		Match.MATCH_STATE.DRAFT:
			if action.selected_pet:
				if cur_match.is_pet_in_center(action.selected_pet):
					action_draft_pet(action.selected_pet)
		
		Match.MATCH_STATE.DURING:
			cur_match.update_passives()
			
			match cur_match.turn_state:
				cur_match.TURN_STATE.TURN_ACTION:
					_process_turn_action(action)
				
				cur_match.TURN_STATE.PET_ACTION:
					var pet_ability_finished := cur_match.get_cur_ability().process_pet_action(cur_match, action)
					if pet_ability_finished:
						cur_match.turn_state = cur_match.TURN_STATE.TURN_ACTION

func _process_turn_action(action : Action):
	if action.selected_pet:
		if cur_match.can_take_turn_roll():
			if cur_match.is_pet_in_cur_player_or_center(action.selected_pet):
				action_roll_dice(action.selected_pet)
	elif action.ending_turn:
		action_end_turn()
	elif action.declared_end:
		if not cur_match.end_declared:
			action_declare_end()

func action_draft_pet(pet_die : PetDie):
	print(pet_die)
	var cur_player_index := cur_match.get_whos_turn()
	var cur_hand_index := cur_player_index + 1
	
	var cur_player_hand := cur_match.get_hand(cur_hand_index)
	
	cur_match.get_center_hand().move_pet_to_hand(pet_die, cur_player_hand)
	board.move_pet_to_hand(cur_hand_index, pet_die)
	
	# check if end of draft
	cur_match.end_turn()
	if cur_match.turn_index >= cur_match.get_draft_turn_legnth():
		cur_match.start_during()
		for board_hand in board.board_hands:
			for dice_hold in board_hand.dice_holds:
				dice_hold.update_label()

func action_roll_dice(pet_die : PetDie):
	cur_match.roll_pet(pet_die, true)

func action_end_turn():
	cur_match.end_turn()
	print("chose to end turn")

func action_declare_end():
	cur_match.end_declared = true
	print("end declared")
