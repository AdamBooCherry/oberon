shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, diffuse_burley, specular_schlick_ggx;

uniform sampler2D blood_noise : source_color;
uniform float speed = 2.0;
uniform float stretch_y = 3.0; 

// Blood Color Gradient (Top Color to Bottom Color)
uniform vec4 blood_top_color : source_color = vec4(0.6, 0.05, 0.05, 1.0);   // Brighter/fresh at top
uniform vec4 blood_bottom_color : source_color = vec4(0.2, 0.0, 0.0, 1.0);  // Darker/congealed at bottom

uniform float threshold : hint_range(0.0, 1.0) = 0.5; 
uniform float smoothness : hint_range(0.0, 0.2) = 0.05;

// Fade applied to the noise input
uniform float fade_start : hint_range(0.0, 1.0) = 0.5; 
uniform float fade_end : hint_range(0.0, 1.0) = 1.0;   

void fragment() {
    // 1. Stretch UVs vertically for long drips
    vec2 scaled_uv = UV * vec2(1.0, stretch_y);
    
    // 2. Sample scrolling noise
    float noise_val = texture(blood_noise, scaled_uv + vec2(0.0, TIME * speed * 0.1)).r;
    
    // 3. Apply vertical fade directly to the noise value *before* thresholding
    // This scales down the noise intensity toward the bottom, tapering off the drips
    float vertical_fade = 1.0 - smoothstep(fade_start, fade_end, UV.y);
    float faded_noise = noise_val * vertical_fade;
    
    // 4. Threshold the faded noise to create the final sharp drip mask
    float drip_mask = smoothstep(threshold, threshold + smoothness, faded_noise);
    
    // 5. Create a color gradient based on vertical screen space or local UV.y
    vec4 final_blood_color = mix(blood_top_color, blood_bottom_color, UV.y);
    
    // 6. Apply outputs
    ALBEDO = final_blood_color.rgb;
    ROUGHNESS = 0.15; // Wet shine
    SPECULAR = 0.8;
    ALPHA = drip_mask;
    
    if (drip_mask <= 0.01) {
        discard;
    }
}