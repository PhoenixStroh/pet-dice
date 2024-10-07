class_name EndGamePanel
extends PanelContainer

@export var who_won_label : Label
@export var player_result_labels : Array[Label]

@export var match_buttons : Control
@export var end_game_buttons : Control

# who_won: -1: tie, 0: player#1, 1: player#2...
func display_end(winner_indexes : Array[Valuation], player_valuations : Array[Valuation]):
	visible = true
	if match_buttons:
		match_buttons.visible = false
	if end_game_buttons:
		end_game_buttons.visible = true
	
	if winner_indexes.size() > 1:
		who_won_label.text = "TIED"
	else:
		who_won_label.text = "PLAYER %s WINS" % (winner_indexes[0].player_index + 1)
	
	for i in player_valuations.size():
		var player_val := player_valuations[i]
		if i < player_result_labels.size():
			player_result_labels[i].text = "Player %s: %s" % [player_valuations[i].player_index + 1, str(player_val)]
