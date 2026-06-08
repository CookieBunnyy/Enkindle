shader_type canvas_item;

uniform vec2 center = vec2(0.5, 0.5);
uniform float radius = 1.0;

void fragment()
{
	vec2 uv = UV;

	float dist = distance(
		uv,
		center
	);

	if (dist > radius)
	{
		COLOR = vec4(0.0,0.0,0.0,1.0);
	}
	else
	{
		discard;
	}
}