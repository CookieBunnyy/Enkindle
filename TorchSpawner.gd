extends Node2D

@export var torch_scene: PackedScene
@export var torch_count: int = 15

@export var spawn_radius := 40.0


func _ready():

	await get_tree().process_frame

	var spawn_points = []

	for child in get_children():

		if child.name.begins_with("SpawnPoint"):
			spawn_points.append(child)

	print("Spawn Points: ", spawn_points.size())

	spawn_points.shuffle()

	var amount_to_spawn = min(
		torch_count,
		spawn_points.size()
	)

	for i in range(amount_to_spawn):

		var torch = torch_scene.instantiate()

		get_parent().add_child(torch)

		var offset = Vector2(
			randf_range(
				-spawn_radius,
				spawn_radius
			),
			randf_range(
				-spawn_radius,
				spawn_radius
			)
		)

		torch.global_position = (
			spawn_points[i].global_position
			+ offset
		)

		print(
			"Spawned Torch Near ",
			spawn_points[i].name,
			" at ",
			torch.global_position
		)
