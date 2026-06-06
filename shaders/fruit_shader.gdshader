shader_type canvas_item;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    // Convert to grayscale
    float gray = dot(tex.rgb, vec3(0.299, 0.587, 0.114));
    // Apply grayscale with original alpha, then multiply by modulate
    COLOR = vec4(vec3(gray), tex.a) * modulate;
}
