extends Node2D

@export var brazier_scene : PackedScene
@export var brazier_count := 4


func _ready():

	# Wait until the scene tree is fully loaded
	await get_tree().process_frame

	var spawn_points = [
		$SpawnPoint1,
		$SpawnPoint2,
		$SpawnPoint3,
		$SpawnPoint4
	]

	for i in range(
		min(brazier_count, spawn_points.size())
	):

		spawn_brazier(
			spawn_points[i]
		)


func spawn_brazier(spawn_point):

	var brazier = brazier_scene.instantiate()

	# Add first
	get_parent().add_child(
		brazier
	)

	# Then position
	brazier.global_position = (
		spawn_point.global_position
	)

	print(
		"Spawn Point Local: ",
		spawn_point.position
	)

	print(
		"Spawn Point Global: ",
		spawn_point.global_position
	)

	print(
		"Brazier Actual Position: ",
		brazier.global_position
	)
