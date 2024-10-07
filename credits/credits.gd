extends Control

@export_file(".tscn") var next_scene : String

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		get_tree().change_scene_to_file(next_scene)
