shader_type canvas_item;

uniform vec3 color_to_replace = vec3(152.0, 91.0, 255.0);
uniform vec3 masque = vec3(28.0, 255.0, 28.0);
uniform float threshold = 0.31;

void fragment() {
    COLOR = texture(TEXTURE, UV);
    if (distance(COLOR.rgb, normalize(color_to_replace)) < threshold) {
        // Replace the color
        COLOR.rgb = normalize(masque);
    }
}