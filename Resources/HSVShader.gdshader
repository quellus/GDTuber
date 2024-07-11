shader_type canvas_item;

uniform float hue : hint_range(-3.14159,3.14159) = 0.0;
uniform float sat : hint_range(0, 2.0) = 1.0;
uniform float val : hint_range(0.0, 1.0) = 0.5;

float rgb2lum(vec3 color) {
	return (color.r+color.g+color.b)/3.0;
}

vec3 hue_shift(vec3 color, float dhue) {
	float s = sin(dhue);
	float c = cos(dhue);
	return (color * c) + (color * s) * mat3(
		vec3(0.167444, 0.329213, -0.496657),
		vec3(-0.327948, 0.035669, 0.292279),
		vec3(1.250268, -1.047561, -0.202707)
	) + dot(vec3(0.299, 0.587, 0.114), color) * (1.0 - c);
}

vec3 applyval(vec3 color) {
	return min(val*2.0, 1.0)*color+max(0, val*2.0-1.0)*(vec3(1)-color);
}

void fragment() {
	vec4 texture_color = texture(TEXTURE, UV);
	vec3 color = hue_shift(texture_color.rgb, hue);
	float lum = rgb2lum(color.rgb);
	color = vec3(lum)+(color.rgb-vec3(lum))*sat;
	color = applyval(color);
	COLOR.rgba = vec4(color.rgb, texture_color.a);
	// vec4(color_rgb.rgb,texture_color.a);
}
