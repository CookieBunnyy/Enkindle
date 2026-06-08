extends TextureRect

var t := 0.0

func _process(delta):

	t += delta

	position.x = sin(t) * 10
	position.y = cos(t * 0.5) * 5
