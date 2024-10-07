class_name MatchDirector
extends Node

@export var starting_pets : Array[PetDie]

@export var board : Board
@export var end_turn_button : Button
@export var declare_end_button : Button

@export var last_turn_panel : Control
@export var rolls_remaining_label : Label
@export var whos_turn_label : Label
@export var end_game_panel : EndGamePanel

var cur_match : Match

func _ready() -> void:
	board.pet_die_interacted.connect(_on_pet_die_interacted)
	
	end_turn_button.pressed.connect(_on_end_turn_button_pressed)
	declare_end_button.pressed.connect(_on_declare_end_button_pressed)
	
	starting_pets = PreMatchData.pets_selected
	
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

func _on_pet_die_moved_to_hand(pet_die : PetDie, hand : Hand):
	board.move_pet_to_hand(hand.hand_index, pet_die)

func _on_pet_die_updated(pet_die : PetDie):
	board.update_pet(pet_die)

func _on_pet_die_lurched(pet_die : PetDie):
	board.lurch_pet(pet_die)

func _on_pet_die_shaken(pet_die : PetDie):
	board.shake_pet(pet_die)

func _on_game_ended(winner_valuations : Array[Valuation], valuations : Array[Valuation]):
	last_turn_panel.visible = false
	if end_game_panel:
		end_game_panel.display_end(winner_valuations, valuations)

func _input(event: InputEvent) -> void:
	if OS.has_feature("debug"):
		if event.is_action_pressed("restart"):
			get_tree().reload_current_scene()

func setup():
	cur_match = Match.new()
	cur_match.pet_die_rolled.connect(_on_pet_die_rolled)
	cur_match.pet_die_lurched.connect(_on_pet_die_lurched)
	cur_match.pet_die_shaken.connect(_on_pet_die_shaken)
	cur_match.pet_die_updated.connect(_on_pet_die_updated)
	cur_match.pet_die_moved_to_hand.connect(_on_pet_die_moved_to_hand)
	cur_match.game_ended.connect(_on_game_ended)
	
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
			if cur_match.is_input_frozen:
				return
			
			cur_match.update_passives()
			
			match cur_match.turn_state:
				cur_match.TURN_STATE.TURN_ACTION:
					_process_turn_action(action)
				
				cur_match.TURN_STATE.PET_ACTION:
					_process_pet_action(action)

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

func _process_pet_action(action : Action):
	var pet_ability_finished := cur_match.get_cur_ability().process_pet_action(cur_match, action)
	if pet_ability_finished:
		cur_match.turn_state = cur_match.TURN_STATE.TURN_ACTION

func action_draft_pet(pet_die : PetDie):
	print(pet_die)
	var cur_player_index := cur_match.get_whos_turn()
	var cur_hand_index := cur_player_index + 1
	
	var cur_player_hand := cur_match.get_hand(cur_hand_index)
	
	cur_match.get_center_hand().move_pet_to_hand(pet_die, cur_player_hand)
	board.move_pet_to_hand(cur_hand_index, pet_die)
	
	# check if end of draft
	cur_match.end_turn()
	
	whos_turn_label.text = "PLAYER %s" % (cur_match.get_whos_turn() + 1)
	
	if cur_match.turn_index >= cur_match.get_draft_turn_legnth():
		cur_match.start_during()
		end_game_panel.match_buttons.visible = true
		rolls_remaining_label.text = str(cur_match.get_rolls_remaining())
		for board_hand in board.board_hands:
			for dice_hold in board_hand.dice_holds:
				dice_hold.update_label()
		
		whos_turn_label.text = "PLAYER %s" % (cur_match.get_whos_turn() + 1)
		board.board_hands[0].spacing = 2.0
		board.board_hands[0].space_hand()

func action_roll_dice(pet_die : PetDie):
	cur_match.is_input_frozen = true
	
	declare_end_button.visible = false
	await cur_match.roll_pet(pet_die, true)
	
	rolls_remaining_label.text = str(cur_match.get_rolls_remaining())
	
	cur_match.is_input_frozen = false

func action_end_turn():
	cur_match.end_turn()
	declare_end_button.visible = true
	
	whos_turn_label.text = "PLAYER %s" % (cur_match.get_whos_turn() + 1)
	rolls_remaining_label.text = str(cur_match.get_rolls_remaining())

func action_declare_end():
	cur_match.end_declared = true
	last_turn_panel.visible = true
