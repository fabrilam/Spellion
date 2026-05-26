shader_type spatial;
render_mode blend_mix, unshaded;

uniform sampler2D albedo_texture : source_color;
uniform sampler2D palette_map : source_color;

void fragment() {
	vec4 c = texture(albedo_texture, UV);
	vec4 p = texture(palette_map, vec2(c.r, c.g));
	ALBEDO = p.rgb;
	ALPHA = c.a;
}
