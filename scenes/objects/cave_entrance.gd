extends StaticBody2D

func interact(_player):
	get_tree().call_deferred("change_scene_to_file", "res://scenes/levels/cave.tscn")
