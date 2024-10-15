shader_type canvas_item;

uniform sampler2D skin;
uniform vec2 skin_dimension;

varying vec4 MODULATE;

void vertex() {
  MODULATE = COLOR;
}

void fragment() {
  vec4 map = texture(TEXTURE, UV);
  vec2 scaled_uv = (map.rg * 255.0 + 0.5) / skin_dimension;
  vec4 color = texture(skin, scaled_uv);
  COLOR = color;
  COLOR.a = map.a * color.a;
  COLOR = COLOR * MODULATE;
}
