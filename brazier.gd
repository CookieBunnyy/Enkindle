extends Area2D

@export var required_embers := 2
@onready var unlit_sprite = $Sprite2D
@onready var lit_sprite = $AnimatedSprite2D
var current_embers := 0
var activated := false
@export var embers_required := 3

var embers_added := 0

@onready var ember_label = $EmberLabel

func _ready():

	add_to_group("brazier")

	ember_label.visible = false

	update_ember_label()

	print(
		"Brazier Actual Position: ",
		global_position
	)
	
func interact(player):

	if activated:
		print("Already activated")
		return

	if player.embers <= 0:
		print("Need embers")
		return

	player.embers -= 1

	var game = get_tree().current_scene

	if game.has_method("update_embers"):
		game.update_embers(player.embers)

	current_embers += 1

	embers_added = current_embers

	update_ember_label()

	print(
		"Player Embers Left: ",
		player.embers
	)

	print(
		"Brazier: ",
		current_embers,
		"/",
		required_embers
	)

	if current_embers >= required_embers:
		activate()


func activate():

	activated = true

	$PointLight2D.enabled = true


	unlit_sprite.visible = false


	lit_sprite.visible = true

	lit_sprite.play("brazier_lit")

	var shade = get_tree().get_first_node_in_group("shade")

	if shade:
		shade.flee_from_light(global_position)

	var game = get_tree().current_scene

	if game.has_method("update_objective"):

		game.lit_braziers += 1
		game.update_objective()

	print("BRAZIER ACTIVATED")
	
	
func update_ember_label():

	if activated:

		ember_label.text = "LIT"

	else:

		ember_label.text = (
			"Press E to Lit\n"
			+ str(current_embers)
			+ " / "
			+ str(required_embers)
			+ " "
		)
