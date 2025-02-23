shader_type canvas_item;

uniform bool on = false;

void fragment(){
	vec4 color = texture(TEXTURE, UV);
	if(on)
	{
		COLOR = vec4(1.0 - color.rgb, color.a);
	}
}