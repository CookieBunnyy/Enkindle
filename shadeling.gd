extends CharacterBody2D

@export var stalk_speed := 120.0
@export var chase_speed := 600.0
@export var minimum_spawn_distance := 500.0

@export var wake_distance := 250.0
@export var chase_distance := 100.0

enum State {
	HIDE,
	STALK,
	CHASE
}

var current_state = State.HIDE

var player = null
var is_marking := false

@onready var animated_sprite = $AnimatedSprite2D


func _ready():

	print("SHADELING READY")

	add_to_group("shadeling")

	player = get_tree().get_first_node_in_group(
		"player"
	)

	spawn_outside_player_view()

	modulate.a = 0.15

	current_state = State.HIDE

	if animated_sprite:
		animated_sprite.play(
			"shade_idle_down"
		)


func _physics_process(delta):

	if player == null:
		return

	if is_marking:
		return

	var distance = global_position.distance_to(
		player.global_position
	)

	match current_state:

		State.HIDE:

			velocity = Vector2.ZERO

			if distance <= wake_distance:

				current_state = State.STALK

				modulate.a = 1.0

				var game = get_tree().current_scene

				if game.has_method(
					"set_alert"
				):
					game.set_alert(
						"SOMETHING IS NEARBY..."
					)

		State.STALK:

			stalk_player()

			if distance <= chase_distance:

				current_state = State.CHASE

		State.CHASE:

			chase_player()

	move_and_slide()


func stalk_player():

	var direction = global_position.direction_to(
		player.global_position
	)

	velocity = direction * stalk_speed

	update_animation(direction)


func chase_player():

	var direction = global_position.direction_to(
		player.global_position
	)

	velocity = direction * chase_speed

	update_animation(direction)


func update_animation(direction):

	if !animated_sprite:
		return

	if abs(direction.x) > abs(direction.y):

		if animated_sprite.animation != "shade_walkside":
			animated_sprite.play(
				"shade_walkside"
			)

		animated_sprite.flip_h = (
			direction.x < 0
		)

	else:

		animated_sprite.flip_h = false

		if direction.y < 0:

			if animated_sprite.animation != "shade_walkup":
				animated_sprite.play(
					"shade_walkup"
				)

		else:

			if animated_sprite.animation != "shade_walkdown":
				animated_sprite.play(
					"shade_walkdown"
				)


func _on_detection_area_body_entered(body):

	if is_marking:
		return

	if !body.is_in_group("player"):
		return

	mark_player(body)


func mark_player(player_body):

	is_marking = true

	velocity = Vector2.ZERO

	if player_body.has_method(
		"set_marked"
	):
		player_body.set_marked(true)

	var game = get_tree().current_scene

	if game.has_method(
		"player_marked"
	):
		game.player_marked()

	if game.has_method(
		"set_alert"
	):
		game.set_alert(
			"YOU HAVE BEEN MARKED"
		)

	if game.has_method(
		"play_shadeling_jumpscare"
	):
		game.play_shadeling_jumpscare()

	print("PLAYER MARKED")

	await get_tree().create_timer(
		0.5
	).timeout

	disappear()


func disappear():

	visible = false

	if has_node(
		"DetectionArea/CollisionShape2D"
	):
		$DetectionArea/CollisionShape2D.disabled = true

	await get_tree().create_timer(
		5.0
	).timeout

	spawn_outside_player_view()

	modulate.a = 0.15

	visible = true

	if has_node(
		"DetectionArea/CollisionShape2D"
	):
		$DetectionArea/CollisionShape2D.disabled = false

	current_state = State.HIDE

	is_marking = false


func spawn_outside_player_view():

	if player == null:
		return

	var spawn_points = get_tree().get_nodes_in_group(
		"shadeling_spawn"
	)

	if spawn_points.is_empty():

		push_warning(
			"No shadeling_spawn points found."
		)

		return

	var valid_points = []

	for point in spawn_points:

		if point.global_position.distance_to(
			player.global_position
		) >= minimum_spawn_distance:

			valid_points.append(point)

	if valid_points.is_empty():

		global_position = (
			spawn_points.pick_random()
			.global_position
		)

	else:

		global_position = (
			valid_points.pick_random()
			.global_position
		)

	print(
		"Shadeling Hidden At: ",
		global_position
	)
