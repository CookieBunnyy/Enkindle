extends Control
@onready var progress_bar = $ProgressBar
@onready var animation_player = $AnimationPlayer

func _ready():
	animation_player.play("Shade")
	$TipLabel.text = tips.pick_random()

	progress_bar.value = 0

	for i in range(101):

		progress_bar.value = i

		await get_tree().create_timer(
			0.02
		).timeout

	get_tree().change_scene_to_file(
		GameData.next_scene
	)

var tips = [
	"Hide in bushes or barrels to evade danger.",
	"The Shadeling's mark reveals your location.",
	"The Shade fears fire.",
	"Footsteps attract unwanted attention.",
	"Stealth can save your life.",
	"Light is your greatest ally."
]
