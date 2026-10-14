shader_type canvas_item;
// Balanço suave da copa de árvores e arbustos. A base do sprite fica fixa.

uniform float strength = 0.8;
uniform float speed = 1.1;

void vertex() {
	float phase = (MODEL_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).x * 0.07;
	float top = 1.0 - UV.y;
	VERTEX.x += sin(TIME * speed + phase) * strength * top * top;
}
