extends Node2D

@export var shade_scene : PackedScene

@onready var shade_spawn_sound = $ShadeSpawnSound
@onready var shadeling_sound = $ShadelingSound
@onready var background_music = $BackgroundMusic
@export var shadeling_scene : PackedScene

var shadelings = []
@onready var level_label = $UI/LevelLabel
@onready var jumpscare_sprite = $UI/JumpscareSprite
@onready var player = $Player
@onready var player_marked_label = $UI/PlayerMarked
@onready var objective_label = $UI/ObjectiveLabel
@onready var ember_counter = $UI/EmberCounter
@onready var alert_label = $UI/AlertLabel
@onready var status_label = $UI/StatusLabel
@onready var victory_label = $UI/VictoryLabel
@export var level_number := 1
@onready var timer_label = $UI/TimerLabel
@onready var shade_countdown = $UI/ShadeCountdown
@onready var skill_cooldown_label = $UI/SkillCooldown
@onready var canvas_modulate = $CanvasModulate
var countdown_time := 300.0
var normal_darkness = Color("212121")
var marked_darkness = Color("080808")
var shade = null
var door = null

const WORLD_WIDTH = 4711
const WORLD_HEIGHT = 2891

var lit_braziers := 0
var required_braziers := 4


func _ready() -> void:

	Input.set_custom_mouse_cursor(
		load("res://Assets/UI/cursor.png")
	)
	if player_marked_label:
		player_marked_label.visible = true
	
	if canvas_modulate:
		canvas_modulate.color = normal_darkness
		
	if shade_countdown:
		shade_countdown.visible = false

	$BrazierSpawner.brazier_count = required_braziers

	get_tree().debug_navigation_hint = false

	update_objective()

	door = get_tree().get_first_node_in_group(
		"door"
	)

	print("Door Found: ", door)

	player.noise_created.connect(
		_on_player_noise
	)

	spawn_real_shade_timer()

	if background_music:
		background_music.play()

	print("MainGame Ready")
	if level_label:

		level_label.visible = true

		level_label.text = (
		"LEVEL "
			+ str(level_number)
	)

	show_level_label()


func _process(delta):

	if timer_label == null:
		return

	if countdown_time > 0:

		countdown_time -= delta

		if countdown_time < 0:
			countdown_time = 0

		var minutes = int(countdown_time) / 60
		var seconds = int(countdown_time) % 60

		timer_label.text = (
			"%02d:%02d" % [minutes, seconds]
		)

	else:

		timer_label.text = "00:00"


func _on_player_noise(position):

	if shade == null:
		return

	if shade.has_method("hear_sound"):
		shade.hear_sound(position)


func spawn_real_shade_timer():

	await get_tree().create_timer(
		60.0
	).timeout

	if !player.marked:

		print(
			"Player was never marked."
		)

		return

	spawn_real_shade()


func spawn_real_shade():

	if shade_countdown:
		shade_countdown.visible = false

	if shade != null:
		return

	var spawn_points = get_tree().get_nodes_in_group(
		"shade_spawn"
	)

	if spawn_points.is_empty():

		push_warning(
			"No shade_spawn points found!"
		)

		return

	var spawn_point = (
		spawn_points.pick_random()
	)

	shade = shade_scene.instantiate()

	add_child(shade)

	shade.global_position = (
		spawn_point.global_position
	)

	if shade_spawn_sound:

		shade_spawn_sound.global_position = (
			shade.global_position
		)

		shade_spawn_sound.play()

	set_alert(
		"THE SHADE HAS AWAKENED"
	)

	print(
		"Real Shade Spawned"
	)


func update_objective():

	objective_label.text = (
		"Braziers Lit: "
		+ str(lit_braziers)
		+ " / "
		+ str(required_braziers)
	)

	if lit_braziers >= required_braziers:

		if door:
			door.unlock()

		var escape_zone = get_tree().get_first_node_in_group(
			"escape_zone"
		)

		if escape_zone:
			escape_zone.unlock()

		player.escape_arrow.visible = true

		set_alert(
			"FIND THE EXIT"
		)


func update_embers(amount):

	ember_counter.text = (
		"Embers: "
		+ str(amount)
	)


func set_alert(text):

	alert_label.text = text


func set_status(text):

	status_label.text = text


func level_complete():

	match level_number:

		1:

			GameData.unlock_level(2)

			GameData.next_scene = "res://level_2.tscn"

			get_tree().change_scene_to_file(
				"res://LoadingScreen.tscn"
			)

		2:

			GameData.unlock_level(3)

			GameData.next_scene = "res://level_3.tscn"

			get_tree().change_scene_to_file(
				"res://LoadingScreen.tscn"
			)

		3:

			GameData.next_scene = "res://Congratulations.tscn"

			get_tree().change_scene_to_file(
				"res://LoadingScreen.tscn"
			)


func play_shadeling_jumpscare():

	if shadeling_sound:
		shadeling_sound.play()

	await get_tree().create_timer(
		0.1
	).timeout

	jumpscare_sprite.visible = true

	jumpscare_sprite.play(
		"shade_jumpscare"
	)

	await jumpscare_sprite.animation_finished

	jumpscare_sprite.visible = false


func _on_restart_button_pressed():

	get_tree().reload_current_scene()


func player_marked():

	if shade != null:
		return

	if shade_countdown:
		shade_countdown.visible = true

	for i in range(10, 0, -1):

		if shade_countdown:

			shade_countdown.text = (
				"SHADE'S APPEARING IN: "
				+ str(i)
			)

		await get_tree().create_timer(
			1.0
		).timeout

		if shade != null:
			return

	if shade_countdown:
		shade_countdown.visible = false

	spawn_real_shade()


func update_skill_cooldown(
	sprint_time,
	stealth_time
):

	if skill_cooldown_label == null:
		return

	var sprint_text = "READY"
	var stealth_text = "READY"

	if sprint_time > 0:

		sprint_text = (
			str(
				ceil(sprint_time)
			)
			+ "s"
		)

	if stealth_time > 0:

		stealth_text = (
			str(
				ceil(stealth_time)
			)
			+ "s"
		)

	skill_cooldown_label.text = (
		"SPRINT: "
		+ sprint_text
		+ "\nSTEALTH: "
		+ stealth_text
	)
	
	
func start_marked_countdown(duration):

	if player_marked_label == null:
		return

	player_marked_label.visible = true


	if canvas_modulate:

		var dark_tween = create_tween()

		dark_tween.tween_property(
			canvas_modulate,
			"color",
			marked_darkness,
			1.5
		)

	for i in range(duration, 0, -1):

		player_marked_label.text = (
			"PLAYER MARKED: "
			+ str(i)
			+ "s"
		)

		await get_tree().create_timer(
			1.0
		).timeout

	player_marked_label.visible = false


	if canvas_modulate:

		var light_tween = create_tween()

		light_tween.tween_property(
			canvas_modulate,
			"color",
			normal_darkness,
			2.0
		)
	
func show_level_label():

	if level_label == null:
		return

	level_label.modulate.a = 1.0

	await get_tree().create_timer(
		2.0
	).timeout

	var tween = create_tween()

	tween.tween_property(
		level_label,
		"modulate:a",
		0.0,
		1.0
	)

	await tween.finished

	level_label.visible = false
