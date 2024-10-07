extends Control

@export var screens : Array[Control]
@export_file(".tscn") var next_scene : String

var cur_index := 0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		cur_index += 1
		if cur_index < screens.size():
			screens[cur_index - 1].visible = false
			screens[cur_index].visible = true
		else:
			get_tree().change_scene_to_file(next_scene)
