extends Camera2D

@export var look_ahead_strength := 0.1
@export var max_offset := 180.0
@export var smooth_speed := 3.0

func _physics_process(delta):

	var viewport_size = Vector2(get_viewport().size)

	var center = viewport_size / 2.0

	var mouse_pos = get_viewport().get_mouse_position()

	var direction = mouse_pos - center

	direction *= look_ahead_strength

	direction = direction.limit_length(max_offset)

	offset = offset.lerp(
		direction,
		smooth_speed * delta
	)
