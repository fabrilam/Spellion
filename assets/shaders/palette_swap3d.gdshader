shader_type spatial;
render_mode blend_mix;

uniform sampler2D albedo_texture : source_color;
uniform sampler2D palette_tex : source_color;
uniform float tolerance = 0.15;

void fragment() {
	vec4 c = texture(albedo_texture, UV);
	vec4 out_c = c;

	for (int i = 0; i < 8; i++) {
		float u = (float(i) + 0.5) / 8.0;
		vec4 src = texture(palette_tex, vec2(u, 0.25));
		if (src.a < 0.01) continue;
		float d = distance(c.rgb, src.rgb);
		if (d < tolerance) {
			vec4 rep = texture(palette_tex, vec2(u, 0.75));
			out_c.rgb = rep.rgb;
			break;
		}
	}

	ALBEDO = out_c.rgb;
	ALPHA = c.a;
}
