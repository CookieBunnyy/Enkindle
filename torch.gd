extends Area2D

@export var ember_value := 1

func interact(player):

	player.embers += ember_value

	print("Embers: ", player.embers)

	var game = get_tree().current_scene

	if game.has_method("update_embers"):
		game.update_embers(player.embers)

	queue_free()
