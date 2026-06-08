extends Control

@onready var background_music = $BGMusic


func _ready():
	Input.set_custom_mouse_cursor(
		load("res://Assets/UI/cursor.png")
	)
	if background_music:
		background_music.play()


	$LevelSelectPanel.visible = false


	if $FadeRect:

		$FadeRect.modulate.a = 1.0

		var tween = create_tween()

		tween.tween_property(
			$FadeRect,
			"modulate:a",
			0.0,
			1.5
		)


	$LevelSelectPanel/Level2Button.disabled = (
		GameData.unlocked_level < 2
	)

	$LevelSelectPanel/Level3Button.disabled = (
		GameData.unlocked_level < 3
	)


func _on_start_button_pressed():

	$VBoxContainer.visible = false

	$LevelSelectPanel.visible = true


func _on_option_button_pressed():

	print("Options pressed")


func _on_quit_button_pressed():

	get_tree().quit()


func _on_level_1_button_pressed():

	GameData.next_scene = "res://level_1.tscn"

	get_tree().change_scene_to_file(
		"res://LoadingScreen.tscn"
	)


func _on_level_2_button_pressed():

	GameData.next_scene = "res://level_2.tscn"

	get_tree().change_scene_to_file(
		"res://LoadingScreen.tscn"
	)


func _on_level_3_button_pressed():

	GameData.next_scene = "res://level_3.tscn"

	get_tree().change_scene_to_file(
		"res://LoadingScreen.tscn"
	)


func _on_back_button_pressed():

	$LevelSelectPanel.visible = false

	$VBoxContainer.visible = true
	
	
func _on_reset_progress_button_pressed():

	GameData.reset_progress()

	print("Progress Reset")
