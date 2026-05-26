shader_type spatial;
render_mode unshaded, blend_mix;

uniform float fill_amount : hint_range(0.0, 1.0) = 1.0;
uniform vec4 fill_color : source_color = vec4(0.0, 0.8, 0.0, 1.0);
uniform vec4 empty_color : source_color = vec4(0.3, 0.0, 0.0, 1.0);

void vertex() {
    mat4 m = MODEL_MATRIX;
    vec3 s = vec3(length(m[0].xyz), length(m[1].xyz), length(m[2].xyz));
    vec4 pos = m[3];

    vec3 r = normalize(INV_VIEW_MATRIX[0].xyz);
    vec3 u = normalize(INV_VIEW_MATRIX[1].xyz);
    vec3 f = normalize(INV_VIEW_MATRIX[2].xyz);

    m[0] = vec4(r * s.x, 0.0);
    m[1] = vec4(u * s.y, 0.0);
    m[2] = vec4(-f * s.z, 0.0);
    m[3] = pos;

    POSITION = PROJECTION_MATRIX * (VIEW_MATRIX * (m * vec4(VERTEX, 1.0)));
}

void fragment() {
    float filled = step(UV.x, fill_amount);
    ALBEDO = mix(empty_color.rgb, fill_color.rgb, filled);
    ALPHA = mix(empty_color.a, fill_color.a, filled);
}
