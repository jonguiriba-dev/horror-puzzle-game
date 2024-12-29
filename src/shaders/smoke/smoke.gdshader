shader_type canvas_item;

uniform sampler2D noise_texture: repeat_enable;
uniform vec4 smoke_color: source_color;
uniform float distortion_speed: hint_range(0.0, 5.0, 0.1) = .5;

float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

void vertex() {
	VERTEX.x += sin(TIME * cos(TIME) * length(random(UV * random(vec2(.5)))) * distortion_speed/ 3.0) * length(random(UV)) * 50.0;
	VERTEX.y += cos(TIME * sin(TIME) * length(random(UV)) * distortion_speed/ 3.0) * length(random(UV)) * 50.0;

}
void fragment() {

	vec4 color = texture(noise_texture, UV + vec2(sin(TIME / 10.0)));
    vec2 uv = UV;

    vec2 centered_uv = uv - vec2(0.5);

    float distance = length(centered_uv);

    float radius = 0.2; // Adjust for how far the effect should extend
    float softness = -0.3; // Adjust for the smoothness of the transparency gradient

    // Compute the transparency based on the distance
    float alpha = smoothstep(radius, radius - softness, distance);

    COLOR = vec4(smoke_color.rgb, color.r);
    COLOR.a *= 1.0 - alpha;

}
