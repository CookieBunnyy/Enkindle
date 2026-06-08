extends Node2D

var unlocked := false

@onready var close_door = $CloseDoor
@onready var open_door = $OpenDoor

@onready var blocker = $DoorBlocker
@onready var exit_area = $ExitArea


func _ready():

	add_to_group("door")

	close_door.visible = true
	open_door.visible = false

	exit_area.body_entered.connect(
		_on_body_entered
	)


func unlock():

	if unlocked:
		return

	unlocked = true

	close_door.visible = false
	open_door.visible = true

	blocker.queue_free()

	print("DOOR OPENED")


func _on_body_entered(body):

	if !unlocked:
		return

	if body.is_in_group("player"):

		print("YOU ESCAPED")

		var game = get_tree().current_scene

		if game.has_method("level_complete"):
			game.level_complete()
