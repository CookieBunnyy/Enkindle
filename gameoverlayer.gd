extends Control

@onready var material_ref = $ColorRect.material
@onready var restart_button = $RestartButton
@onready var game_over_label = $GameOverLabel

var radius := 2.0

var active := false
var restarting := false


func _ready():

	restart_button.visible = false
	game_over_label.visible = false

	material_ref.set_shader_parameter(
		"radius",
		2.0
	)


func start_game_over():

	var player = get_tree().get_first_node_in_group("player")

	if player:
		player.set_physics_process(false)

	var viewport_size = get_viewport().size

	var screen_pos = player.get_global_transform_with_canvas().origin

	var uv_center = Vector2(
		screen_pos.x / viewport_size.x,
		screen_pos.y / viewport_size.y
	)

	material_ref.set_shader_parameter(
		"center",
		uv_center
	)

	radius = 2.0

	active = true


func _process(delta):


	if active:

		radius -= delta

		material_ref.set_shader_parameter(
			"radius",
			radius
		)

		if radius <= 0:

			radius = 0

			active = false

			game_over_label.visible = true
			restart_button.visible = true


	elif restarting:

		radius += delta

		material_ref.set_shader_parameter(
			"radius",
			radius
		)

		if radius >= 2.0:

			radius = 2.0

			restarting = false

			get_tree().reload_current_scene()


func _on_restart_button_pressed():

	restart_button.visible = false
	game_over_label.visible = false

	restarting = true

	radius = 0.0
