shader_type canvas_item;

void fragment() {
    vec2 uv = UV - vec2(0.5); // center UVs around (0,0)
    float dist = length(uv);

    if (dist > 0.5) {
        discard; // remove pixels outside the circle
    }

    COLOR = texture(TEXTURE, UV);
}

