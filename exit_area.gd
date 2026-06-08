extends Area2D

func _on_body_entered(body):

	if body.is_in_group("player"):

		print("YOU ESCAPED")

		var game = get_tree().current_scene

		if game.has_method("level_complete"):
			game.level_complete()
