class_name MatchDirector
extends Node

@export var starting_pets : Array[PetDie]

@export var board : Board

var cur_match : Match

func _ready() -> void:
	board.dice_hold_interacted.connect(_on_dice_hold_interacted)
	
	setup()

func _on_dice_hold_interacted(hand_index : int, pet_index : int):
	var action = Action.new()
	action.selected_pet = cur_match.get_hand(hand_index).get_pet_by_index(pet_index)
	process_action(action)

func setup():
	cur_match = Match.new()
	
	# Setup
	cur_match.setup(starting_pets)
	board.setup(cur_match.get_hands().size(), cur_match.get_center_hand())
	
	cur_match.start_draft()

func process_action(action : Action):
	# Draft Actions
	if cur_match.match_state == Match.MATCH_STATE.DRAFT:
		if action.selected_pet:
			print(action.selected_pet)
