extends Area2D

var unlocked := false

func unlock():

	unlocked = true

	print("Escape Unlocked")


func _on_body_entered(body):

	if !unlocked:
		return

	if body.is_in_group("player"):

		body.escape_arrow.visible = false

		var game = get_tree().current_scene

		game.level_complete()
