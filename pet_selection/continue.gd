extends Button

@export var next_scene : PackedScene

func _pressed() -> void:
	if next_scene:
		get_tree().change_scene_to_packed(next_scene)
