extends Panel

@export var world_left := -2041.0
@export var world_top := -1109.6

@export var world_width := 4711.0
@export var world_height := 2890.6

@onready var player_dot = $PlayerDot
@onready var shade_dot = $ShadeDot

var brazier_dots = {}


func _ready():

	player_dot.color = Color.GREEN
	shade_dot.color = Color.RED


func _process(delta):

	update_player()
	update_shade()


	sync_braziers()

	update_braziers()


func update_player():

	var player = get_tree().get_first_node_in_group(
		"player"
	)

	if player == null:
		return

	player_dot.position = (
		world_to_minimap(
			player.global_position
		)
		- player_dot.size / 2
	)


func update_shade():

	var shade = get_tree().get_first_node_in_group(
		"shade"
	)

	if shade == null:
		return

	shade_dot.position = (
		world_to_minimap(
			shade.global_position
		)
		- shade_dot.size / 2
	)


func sync_braziers():

	var braziers = get_tree().get_nodes_in_group(
		"brazier"
	)

	for brazier in braziers:

		if brazier_dots.has(brazier):
			continue

		var dot = ColorRect.new()

		dot.color = Color.YELLOW

		dot.custom_minimum_size = Vector2(
			8,
			8
		)

		dot.size = Vector2(
			8,
			8
		)

		add_child(dot)

		brazier_dots[brazier] = dot

		print(
			"Minimap Added Brazier Dot"
		)

	# Remove deleted braziers
	for brazier in brazier_dots.keys():

		if is_instance_valid(brazier):
			continue

		var dot = brazier_dots[brazier]

		if is_instance_valid(dot):
			dot.queue_free()

		brazier_dots.erase(brazier)


func update_braziers():

	for brazier in brazier_dots.keys():

		if !is_instance_valid(brazier):
			continue

		var dot = brazier_dots[brazier]

		dot.position = (
			world_to_minimap(
				brazier.global_position
			)
			- dot.size / 2
		)

		# Lit / Unlit color
		if brazier.get("activated") != null:

			if brazier.activated:
				dot.color = Color.CYAN
			else:
				dot.color = Color.YELLOW

func world_to_minimap(world_pos):

	var map_size = size

	var x = (
		(world_pos.x - world_left)
		/ world_width
	) * map_size.x

	var y = (
		(world_pos.y - world_top)
		/ world_height
	) * map_size.y

	x = clamp(
		x,
		4,
		map_size.x - 4
	)

	y = clamp(
		y,
		4,
		map_size.y - 4
	)

	return Vector2(
		x,
		y
	)
