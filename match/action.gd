class_name Action
extends Resource

var selected_pet : PetDie
# -1: no hand selected, 0: center hand, 1: player#1, 2: player#2...
var selected_hand_index := -1

var stop_current_action := false

var declare_end := false
var ending_turn := false
