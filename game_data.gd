extends Node

var unlocked_level := 1
var next_scene := ""

func _ready():

	load_data()

func unlock_level(level):

	if level > unlocked_level:

		unlocked_level = level

	save_data()

func reset_progress():

	unlocked_level = 1

	save_data()

func save_data():

	var file = FileAccess.open(
		"user://save.dat",
		FileAccess.WRITE
	)

	file.store_var(unlocked_level)

func load_data():

	if !FileAccess.file_exists(
		"user://save.dat"
	):
		return

	var file = FileAccess.open(
		"user://save.dat",
		FileAccess.READ
	)

	unlocked_level = file.get_var()
