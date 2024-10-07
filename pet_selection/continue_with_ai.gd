extends Node

@export_file(".tscn") var next_scene : String
@export var playing_with_ai := false

func _pressed() -> void:
	if next_scene:
		PreMatchData.playing_with_ai = playing_with_ai
		get_tree().change_scene_to_file(next_scene)
