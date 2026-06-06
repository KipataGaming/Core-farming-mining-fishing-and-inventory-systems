extends Control

var tool_enum: int

func setup(new_tool_enum: int, main_texture: Texture2D):
	tool_enum = new_tool_enum
	$TextureRect.texture = main_texture

func highlight(selected: bool):
	var tween = create_tween()
	var target_scale = Vector2(1.5, 1.5) if selected else Vector2(1.0, 1.0)
	var target_modulate = Color.WHITE if selected else Color(0.7, 0.7, 0.7, 0.8)
	
	tween.set_parallel(true)
	tween.tween_property($TextureRect, "scale", target_scale, 0.1)
	tween.tween_property($TextureRect, "modulate", target_modulate, 0.1)
