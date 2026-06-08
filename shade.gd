extends CharacterBody2D

@export var move_speed := 70.0
@export var detection_range := 180.0
@export var roam_speed := 50.0

enum State {
	ROAM,
	IDLE,
	INVESTIGATE,
	SEARCH,
	CHASE,
	FLEE
}
var roam_target := Vector2.ZERO
var current_state = State.ROAM
var target_position := Vector2.ZERO
var flee_position := Vector2.ZERO
var last_heard_position := Vector2.ZERO
var investigating := false
var player = null
var player_caught := false
var can_hear_sound := true
var search_duration := 3.0
var searching := false
@onready var fleeing_sound = $FleeingSound
@onready var gameover_sound = $GameOverSound
@onready var animated_sprite = $AnimatedSprite2D
@onready var nav_agent = $NavigationAgent2D



func _ready():
	add_to_group("shade")
	player = get_tree().get_first_node_in_group("player")

	await get_tree().physics_frame


	choose_roam_target()
	animated_sprite.play("shade_idle_down")

func _physics_process(delta):
	if player_caught or player == null:
		return

	match current_state:

		State.ROAM:
			roam()

		State.INVESTIGATE:
			move_to_sound()

		State.SEARCH:
			search()

		State.CHASE:
			chase_player()

		State.FLEE:
			move_to_flee_position()


	var dist_to_player = global_position.distance_to(player.global_position)
	if dist_to_player <= detection_range and not player.hiding_in_barrel and not player.is_stealth:
		current_state = State.INVESTIGATE
		nav_agent.target_position = player.global_position
		
	if player.marked:

		current_state = State.CHASE

		nav_agent.target_position = (
		player.global_position
	)

	elif can_see_player():

		current_state = State.CHASE

		nav_agent.target_position = (
		player.global_position
	)

	move_and_slide()


func choose_roam_target():

	var roam_points = get_tree().get_nodes_in_group(
		"shade_roam"
	)

	print("Roam Points Found:", roam_points.size())

	if roam_points.is_empty():
		return

	var point = roam_points.pick_random()

	print("Going to:", point.name)

	roam_target = point.global_position

	nav_agent.target_position = roam_target
	
	
func roam():

	if nav_agent.is_navigation_finished():

		choose_roam_target()

	var next_position = (
		nav_agent.get_next_path_position()
	)

	var direction = global_position.direction_to(
		next_position
	)

	velocity = direction * 50

	update_animation(direction)


func hear_sound(sound_position):

	if !can_hear_sound:
		return

	if player_caught:
		return

	if current_state == State.CHASE:
		return

	target_position = sound_position

	nav_agent.target_position = (
		sound_position
	)

	current_state = State.INVESTIGATE
func search():

	velocity = Vector2.ZERO

func player_stealthed():

	start_search()

	var game = get_tree().current_scene

	if game.has_method("set_alert"):

		game.set_alert(
			"The Shade Lost Your Trail"
		)

func player_stealth_ended():
	current_state = State.ROAM
	var game = get_tree().current_scene
	if game.has_method("set_alert"):
		game.set_alert("The Darkness Is Quiet...")


func move_to_sound():
	if nav_agent.is_navigation_finished():
		velocity = Vector2.ZERO
		start_search()
		play_idle_from_direction(global_position.direction_to(target_position))
		return

	var next_position = nav_agent.get_next_path_position()
	var direction = global_position.direction_to(next_position)
	velocity = direction * move_speed
	update_animation(direction)

func flee_from_light(light_position):
	can_hear_sound = false
	current_state = State.FLEE

	if fleeing_sound:
		fleeing_sound.pitch_scale = randf_range(0.95, 1.05)
		fleeing_sound.play()

	var flee_direction = (global_position - light_position).normalized()
	flee_position = global_position + flee_direction * 500
	nav_agent.target_position = flee_position
	update_animation(flee_direction)

	await get_tree().create_timer(10.0).timeout

	can_hear_sound = true
	current_state = State.ROAM
	play_idle_from_direction(flee_direction)

func move_to_flee_position():
	if nav_agent.is_navigation_finished():
		velocity = Vector2.ZERO
		current_state = State.ROAM
		return

	var next_position = nav_agent.get_next_path_position()
	var direction = global_position.direction_to(next_position)
	velocity = direction * move_speed * 1.5
	update_animation(direction)


func update_animation(direction: Vector2):
	if not animated_sprite:
		return
	if animated_sprite.animation == "shade_gameover":
		return
	if velocity.length() <= 5:
		play_idle_from_direction(direction)
		return

	if abs(direction.x) > abs(direction.y):
		if animated_sprite.animation != "shade_walk_side":
			animated_sprite.play("shade_walk_side")
		animated_sprite.flip_h = direction.x < 0
	else:
		animated_sprite.flip_h = false
		if direction.y < 0:
			if animated_sprite.animation != "shade_walk_up":
				animated_sprite.play("shade_walk_up")
		else:
			if animated_sprite.animation != "shade_walk_down":
				animated_sprite.play("shade_walk_down")

func play_idle_from_direction(direction: Vector2):
	if not animated_sprite:
		return
	if abs(direction.x) > abs(direction.y):
		if animated_sprite.animation != "shade_idle_side":
			animated_sprite.play("shade_idle_side")
		animated_sprite.flip_h = direction.x < 0
	else:
		animated_sprite.flip_h = false
		if direction.y < 0:
			if animated_sprite.animation != "shade_idle_up":
				animated_sprite.play("shade_idle_up")
		else:
			if animated_sprite.animation != "shade_idle_down":
				animated_sprite.play("shade_idle_down")


func _on_detection_area_body_entered(body):
	if player_caught or body.name != "Player":
		return

	player_caught = true
	can_hear_sound = false
	current_state = State.IDLE
	velocity = Vector2.ZERO
	body.set_physics_process(false)

	if body.has_node("AnimatedSprite2D"):
		body.get_node("AnimatedSprite2D").visible = false

	var camera = get_viewport().get_camera_2d()
	if camera:
		global_position = camera.global_position

	animated_sprite.flip_h = false
	animated_sprite.play("shade_gameover")

	if gameover_sound:
		gameover_sound.play()

	await animated_sprite.animation_finished

	var gameover = get_tree().get_first_node_in_group("gameover")
	if gameover:
		gameover.start_game_over()
		
		
func can_see_player():

	if player == null:
		return false

	if player.hiding_in_barrel:
		return false

	if player.is_stealth:
		return false

	var dist = global_position.distance_to(
		player.global_position
	)

	return dist <= detection_range
	
	
	
func chase_player():

	if player == null:
		return

	nav_agent.target_position = (
		player.global_position
	)

	if nav_agent.is_navigation_finished():
		return

	var next_position = (
		nav_agent.get_next_path_position()
	)

	var direction = global_position.direction_to(
		next_position
	)

	velocity = direction * move_speed

	update_animation(direction)
	
	
func start_search():

	if searching:
		return

	searching = true

	current_state = State.SEARCH

	velocity = Vector2.ZERO

	animated_sprite.play(
		"shade_investigating"
	)

	await get_tree().create_timer(
		search_duration
	).timeout

	searching = false

	if current_state == State.SEARCH:

		current_state = State.ROAM

		choose_roam_target()
