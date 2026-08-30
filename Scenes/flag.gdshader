shader_type spatial;
render_mode cull_disabled;

uniform vec4 flat_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float wind_strength = 1.0;
uniform float wind_speed = 1.0;
uniform float wind_angle = 0.2;
uniform float wind_phase = 0.0;
/**
 * Pin the vertices on the left edge of the flag. Assumes you're using a default 2 x 2 plane.
*/
uniform bool pin = true;

void vertex() {
    float strength = wind_strength * 0.15;
    if (pin) strength *= smoothstep(-1.0, 0.0, VERTEX.x);
    
    float a = PI * 2.0;
    float b = wind_speed * -PI * 2.0 * TIME + wind_phase;
    float t = VERTEX.x * cos(wind_angle) + VERTEX.z * sin(wind_angle);
    float f_t = strength * sin(a * t + b);
    float df_dt = strength * a * cos(a * t + b);
    VERTEX.y += f_t;
    NORMAL.x = -df_dt;
    NORMAL.z = -df_dt;
}

void fragment() {
    ALBEDO = flat_color.rgb;
    ALPHA = flat_color.a;
}