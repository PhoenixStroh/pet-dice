extends Node

func create_timer(time_sec : float) -> SceneTreeTimer:
	return get_tree().create_timer(time_sec)
