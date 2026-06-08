extends CharacterBody2D

signal noise_created(position)

@export var move_speed = 80.0
@export var sprint_speed = 165.0
@export var sprint_duration = 3.0
var sprint_cooldown := 10.0
var stealth_cooldown := 15.0
@export var stealth_duration = 4.0
var marked := false
var last_direction := Vector2.DOWN
var is_sprinting = false
var is_stealth = false
var hiding_in_barrel := false
var current_barrel = null
var current_interactable = null
var embers = 0
var arrow_radius := 30.0
@onready var escape_arrow = $EscapeArrow
@onready var footstep_sound = $Audio/FootstepPlayer
@onready var animated_sprite = $AnimatedSprite2D
@onready var stealth_bomb = $StealthBomb
@onready var sprint_trail = $SprintTrail
@onready var hide_prompt = $HidePrompt
@onready var brazier_prompt = $BrazierPrompt
@onready var ember_prompt = $EmberPrompt
func _ready():
	escape_arrow.visible = false
	hide_prompt.visible = false
	brazier_prompt.visible = false
	ember_prompt.visible = false
	add_to_group("player")

	$FootstepTimer.start()

	sprint_trail.visible = false

	animated_sprite.play("flint_idle_down")


func _physics_process(delta):
	update_escape_arrow()

	if sprint_cooldown > 0:
		sprint_cooldown -= delta
	if sprint_cooldown < 0:
		sprint_cooldown = 0

	if stealth_cooldown > 0:
		stealth_cooldown -= delta
	if stealth_cooldown < 0:
		stealth_cooldown = 0


	var game = get_tree().current_scene
	if game.has_method("update_skill_cooldown"):
		game.update_skill_cooldown(sprint_cooldown, stealth_cooldown)


	if hiding_in_barrel:
		velocity = Vector2.ZERO
		move_and_slide()
		return


	var input_dir = Input.get_vector("move_left","move_right","move_up","move_down")
	if is_sprinting:
		velocity = input_dir * sprint_speed
	else:
		velocity = input_dir * move_speed

	move_and_slide()

	if velocity == Vector2.ZERO and footstep_sound.playing:
		footstep_sound.stop()

	update_animation(input_dir)


func update_animation(direction: Vector2):
	if direction == Vector2.ZERO:
		if abs(last_direction.x) > abs(last_direction.y):
			animated_sprite.play("flint_idle_side")
			animated_sprite.flip_h = last_direction.x < 0
		elif last_direction.y < 0:
			animated_sprite.play("flint_idle_up")
		else:
			animated_sprite.play("flint_idle_down")
		return

	last_direction = direction

	if abs(direction.x) > abs(direction.y):
		animated_sprite.play("flint_walkside")
		animated_sprite.flip_h = direction.x < 0
	else:
		if direction.y < 0:
			animated_sprite.play("flint_walkup")
		else:
			animated_sprite.play("flint_walkdown")


func sprint():

	if is_sprinting:
		return

	if sprint_cooldown > 0:
		print("Sprint cooldown")
		return

	is_sprinting = true

	animated_sprite.speed_scale = 1.6

	var game = get_tree().current_scene

	if game.has_method("set_status"):
		game.set_status("SPRINT ACTIVE")

	print("Sprint Started")

	await get_tree().create_timer(
		sprint_duration
	).timeout

	is_sprinting = false

	animated_sprite.speed_scale = 1.0

	sprint_trail.visible = false

	if game.has_method("set_status"):
		game.set_status("NORMAL")


	sprint_cooldown = 10.0

	print("Sprint Ended")

func stealth():

	if is_stealth:
		return

	if stealth_cooldown > 0:
		print("Stealth cooldown")
		return

	is_stealth = true

	var shade = get_tree().get_first_node_in_group(
		"shade"
	)

	if shade:
		shade.player_stealthed()

	animated_sprite.modulate.a = 0.4


	stealth_bomb.visible = true
	stealth_bomb.stop()
	stealth_bomb.frame = 0
	stealth_bomb.play("stealth_bomb")

	var game = get_tree().current_scene

	if game.has_method("set_status"):
		game.set_status("STEALTH ACTIVE")

	print("Stealth Started")

	await get_tree().create_timer(
		stealth_duration
	).timeout

	is_stealth = false

	animated_sprite.modulate.a = 1.0

	if shade:
		shade.player_stealth_ended()

	if game.has_method("set_status"):
		game.set_status("NORMAL")


	stealth_cooldown = 15.0

	print("Stealth Ended")


func _input(event):
	if event.is_action_pressed("dash"):
		sprint()
	elif event.is_action_pressed("stealth"):
		stealth()
	elif event.is_action_pressed("interact"):
		if hiding_in_barrel:
			exit_barrel()
		elif current_barrel:
			hide_in_barrel(current_barrel)
		else:
			interact()


func _on_interaction_area_area_entered(area):

	current_interactable = area
	
	if area.is_in_group("ember"):

		ember_prompt.visible = true

	if area.is_in_group("barrel"):

		current_barrel = area

		hide_prompt.visible = true

	if area.is_in_group("brazier"):

		if area.has_node("EmberLabel"):

			area.get_node("EmberLabel").visible = true


func _on_interaction_area_area_exited(area):

	if area.is_in_group("barrel"):

		current_barrel = null

		hide_prompt.visible = false

	if area.is_in_group("brazier"):

		if area.has_node("EmberLabel"):

			area.get_node("EmberLabel").visible = false
			
	if area.is_in_group("ember"):

		ember_prompt.visible = false


func hide_in_barrel(barrel):
	
	if hiding_in_barrel:
		return
	hiding_in_barrel = true
	current_barrel = barrel
	visible = false
	velocity = Vector2.ZERO
	global_position = barrel.global_position
	if hide_prompt:
		hide_prompt.visible = false

	var shade = get_tree().get_first_node_in_group("shade")
	if shade:
		shade.player_stealthed()
	print("Player is hiding in barrel")


func exit_barrel():
	if not hiding_in_barrel:
		return
	hiding_in_barrel = false
	visible = true
	current_barrel = null

	var shade = get_tree().get_first_node_in_group("shade")
	if shade:
		shade.player_stealth_ended()
	print("Player exited barrel")


func interact():
	if current_interactable and current_interactable.has_method("interact"):
		current_interactable.interact(self)


func _on_footstep_timer_timeout():
	if velocity == Vector2.ZERO or is_stealth:
		return
	noise_created.emit(global_position)
	if footstep_sound:
		footstep_sound.pitch_scale = randf_range(0.95, 1.05)
		footstep_sound.play()
func _on_stealth_bomb_animation_finished():

	stealth_bomb.visible = false

	stealth_bomb.stop()

	stealth_bomb.frame = 0
	
	
func set_marked(value):

	if marked:
		return

	marked = value

	var game = get_tree().current_scene

	if game.has_method(
		"start_marked_countdown"
	):
		game.start_marked_countdown(10)

	print("PLAYER MARKED")

	await get_tree().create_timer(
		10.0
	).timeout

	marked = false

	print("MARK EXPIRED")



func update_escape_arrow():

	if !escape_arrow.visible:
		return

	var escape_zone = get_tree().get_first_node_in_group(
		"escape_zone"
	)

	if escape_zone == null:
		return

	var direction = (
		escape_zone.global_position
		- global_position
	).normalized()


	escape_arrow.position = direction * arrow_radius


	escape_arrow.rotation = direction.angle() + PI / 2
