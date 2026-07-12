shader_type spatial;
render_mode cull_disabled;

uniform vec2 scroll_speed = vec2(0.0, -0.5);
uniform vec2 uv_offset = vec2(0.0, 0.0);
uniform sampler2D texture_albedo : source_color;

void vertex() {
    vec2 scaled_uv = UV + uv_offset.xy;
    scaled_uv += scroll_speed * TIME;
    UV = scaled_uv;
}

void fragment() {
    vec4 albedo_tex = texture(texture_albedo, UV);
    ALBEDO = albedo_tex.rgb;
}
