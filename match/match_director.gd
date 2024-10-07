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
	if is_users_turn():
		process_action(action)

func _on_declare_end_button_pressed():
	var action := Action.new()
	action.declared_end = true
	if is_users_turn():
		process_action(action)

func _on_pet_die_interacted(pet_die : PetDie):
	var action = Action.new()
	action.selected_pet = pet_die
	if is_users_turn():
		process_action(action)

func _on_pet_die_rolled(pet_die : PetDie):
	print("rolled ", pet_die)
	board.roll_pet_to_index(pet_die)

func _on_pet_die_moved_to_hand(pet_die : PetDie, hand : Hand):
	board.move_pet_to_hand(hand.hand_index, pet_die)

func _on_pet_die_updated(pet_die : PetDie):
	board.update_pet(pet_die)

func _on_pet_die_lurched(pet_die : PetDie, play_sound := true):
	board.lurch_pet(pet_die, play_sound)

func _on_pet_die_shaken(pet_die : PetDie, play_sound := true):
	board.shake_pet(pet_die, play_sound)

func _on_pet_die_constant_shaken(pet_die : PetDie, is_shaking : bool):
	if is_shaking:
		board.play_constant_shake_on_pet(pet_die)
	else:
		board.stop_animation_on_pet(pet_die)

func _on_pet_die_abilitied(pet_die : PetDie):
	board.play_ability_sfx(pet_die)

func _on_game_ended(winner_valuations : Array[Valuation], valuations : Array[Valuation]):
	last_turn_panel.visible = false
	if end_game_panel:
		end_game_panel.display_end(winner_valuations, valuations)

func _on_input_frozen_changed(_is_input_frozen : bool):
	_set_end_button_disabled()

func _on_turn_state_changed(_new_turn_state : Match.TURN_STATE):
	_set_end_button_disabled()

func _is_ai_hand_good_enough() -> bool:
	var ai_hand := cur_match.get_player_hand(1)
	var player_hand := cur_match.get_player_hand(0)
	
	var ai_val := cur_match.valuate_hand(ai_hand)
	var player_val := cur_match.valuate_hand(player_hand)
	
	var comparison := ai_val.is_this_valuation_better(player_val)
	if comparison == -1:
		print("ai hand is currently better")
		if ai_val.hand_pattern > Valuation.HAND_PATTERN.HIGHEST_NUMBER:
			return true
	print("ai hand is not better")
	return false

func _on_turn_ended():
	if not is_users_turn():
		print("AI TURN!")
		_set_end_button_disabled()
		
		await get_tree().create_timer(0.3).timeout
		
		match cur_match.match_state:
			Match.MATCH_STATE.DRAFT:
				var action := Action.new()
				action.selected_pet = cur_match.get_center_hand().get_pets().pick_random()
				process_action(action)
			Match.MATCH_STATE.DURING:
				if not cur_match.can_take_turn_roll():
					var action := Action.new()
					action.ending_turn = true
					process_action(action)
					return

				if cur_match.can_declare_end() and _is_ai_hand_good_enough():
					var declare_action := Action.new()
					declare_action.declared_end = true
					process_action(declare_action)
					
					await get_tree().create_timer(0.3).timeout
					
					var end_turn_action := Action.new()
					end_turn_action.ending_turn = true
					process_action(end_turn_action)
				else:
					var action := Action.new()
					while true:
						var pet : PetDie = cur_match.get_center_hand().get_pets().pick_random()
						if not pet.is_locked:
							action.selected_pet = pet
							break
					
					process_action(action)
					
					await get_tree().create_timer(2.3).timeout
					
					match action.selected_pet.name:
						"Armadillo":
							print("ai armadillo")
							if cur_match.turn_state == Match.TURN_STATE.TURN_ACTION:
								await get_tree().create_timer(1.0).timeout
								_on_turn_ended()
								return
							if cur_match.turn_state == Match.TURN_STATE.PET_ACTION:
								for i in range(randi() % 3 + 1):
									if cur_match.turn_state == Match.TURN_STATE.TURN_ACTION:
										await get_tree().create_timer(1.0).timeout
										_on_turn_ended()
										return
									if cur_match.turn_state == Match.TURN_STATE.PET_ACTION:
										process_action(action)
										await get_tree().create_timer(2.3).timeout
							
							action.selected_pet = null
							action.declared_end = true
							process_action(action)
							await get_tree().create_timer(1.0).timeout
							_on_turn_ended()
							return
						"Sheep":
							print("ai sheep")
							if cur_match.turn_state == Match.TURN_STATE.TURN_ACTION:
								await get_tree().create_timer(1.0).timeout
								_on_turn_ended()
								return
							if cur_match.turn_state == Match.TURN_STATE.PET_ACTION:
								action.selected_pet = cur_match.get_player_hand(0).get_pets().pick_random()
								
								process_action(action)
								await get_tree().create_timer(1.0).timeout
								_on_turn_ended()
								return
						"Magpie":
							print("ai magpie")
							action.selected_pet = cur_match.get_player_hand(0).get_pets().pick_random()
							
							process_action(action)
							await get_tree().create_timer(1.0).timeout
							_on_turn_ended()
							return
						
						"Spider":
							print("ai spider")
							if cur_match.turn_state == Match.TURN_STATE.TURN_ACTION:
								await get_tree().create_timer(1.0).timeout
								_on_turn_ended()
								return
							if cur_match.turn_state == Match.TURN_STATE.PET_ACTION:
								while true:
									var pet = cur_match.get_player_hand(0).get_pets().pick_random()
									
									if not pet.is_locked:
										action.selected_pet = pet
										process_action(action)
										await get_tree().create_timer(1.0).timeout
										_on_turn_ended()
										return
						
						"Jellyfish":
							print("ai jellyfish")
							if cur_match.turn_state == Match.TURN_STATE.TURN_ACTION:
								await get_tree().create_timer(1.0).timeout
								_on_turn_ended()
								return
							if cur_match.turn_state == Match.TURN_STATE.PET_ACTION:
								while true:
									var pet = cur_match.get_player_hand(0).get_pets().pick_random()
									
									if not pet.is_locked:
										action.selected_pet = pet
										process_action(action)
										await get_tree().create_timer(3.0).timeout
										_on_turn_ended()
										return
						_:
							print("ai something")
							process_action(action)
							await get_tree().create_timer(2.0).timeout
							_on_turn_ended()
							return

func _set_end_button_disabled():
	end_turn_button.disabled = (cur_match.is_input_frozen or cur_match.turn_state == Match.TURN_STATE.PET_ACTION) or not is_users_turn()
	if not is_users_turn():
		declare_end_button.disabled = true

func _input(event: InputEvent) -> void:
	if OS.has_feature("debug"):
		if event.is_action_pressed("restart"):
			get_tree().reload_current_scene()
	
	if event.is_action_pressed("cancel"):
		var action = Action.new()
		action.stop_current_action = true
		if is_users_turn():
			process_action(action)

func setup():
	cur_match = Match.new()
	cur_match.pet_die_rolled.connect(_on_pet_die_rolled)
	cur_match.pet_die_lurched.connect(_on_pet_die_lurched)
	cur_match.pet_die_shaken.connect(_on_pet_die_shaken)
	cur_match.pet_die_constant_shaken.connect(_on_pet_die_constant_shaken)
	cur_match.pet_die_abilitied.connect(_on_pet_die_abilitied)
	cur_match.pet_die_updated.connect(_on_pet_die_updated)
	cur_match.pet_die_moved_to_hand.connect(_on_pet_die_moved_to_hand)
	cur_match.game_ended.connect(_on_game_ended)
	cur_match.turn_ended.connect(_on_turn_ended)
	
	cur_match.input_frozen_changed.connect(_on_input_frozen_changed)
	cur_match.turn_state_changed.connect(_on_turn_state_changed)
	
	# Setup
	cur_match.setup(starting_pets)
	board.setup(cur_match.get_center_hand())
	
	cur_match.start_draft()

func is_users_turn() -> bool:
	return not PreMatchData.playing_with_ai or (cur_match.get_whos_turn() == 0)

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
		if not action.selected_pet.is_locked:
			if cur_match.can_take_turn_roll():
				if cur_match.is_pet_in_cur_player_or_center(action.selected_pet):
					action_roll_dice(action.selected_pet)
	elif action.ending_turn:
		action_end_turn()
	elif action.declared_end:
		if not cur_match.end_declared:
			action_declare_end()

func _process_pet_action(action : Action):
	if action.stop_current_action:
		if not cur_match.is_input_frozen and cur_match.cur_pet_dice:
			if cur_match.cur_pet_dice.ability:
				if not cur_match.cur_pet_dice.ability.is_ability_forced:
					cur_match.end_pet_turn()
					return
	
	var pet_ability_finished := await cur_match.get_cur_ability().process_pet_action(cur_match, action)
	if pet_ability_finished:
		cur_match.end_pet_turn()

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
		
		if PreMatchData.playing_with_ai:
			await get_tree().create_timer(2.1).timeout
			_on_turn_ended()

func action_roll_dice(pet_die : PetDie):
	cur_match.is_input_frozen = true
	
	declare_end_button.disabled = true
	await cur_match.roll_pet(pet_die, true)
	
	rolls_remaining_label.text = str(cur_match.get_rolls_remaining())
	
	cur_match.is_input_frozen = false

func action_end_turn():
	cur_match.end_turn()
	if cur_match.can_declare_end() and not cur_match.end_declared:
		declare_end_button.disabled = false
	else:
		declare_end_button.disabled = true
	
	whos_turn_label.text = "PLAYER %s" % (cur_match.get_whos_turn() + 1)
	rolls_remaining_label.text = str(cur_match.get_rolls_remaining())
	_set_end_button_disabled()

func action_declare_end():
	cur_match.end_declared = true
	last_turn_panel.visible = true
	declare_end_button.disabled = true
