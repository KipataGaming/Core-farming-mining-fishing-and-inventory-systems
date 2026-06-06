extends Node2D

var highlight_pos: Vector2 = Vector2.ZERO
var show_highlight: bool = false
var highlight_size: Vector2 = Vector2(48, 48) # 3x3 tiles at 16px each

func _draw():
	if show_highlight:
		# Draw a rectangle outline to highlight the 3x3 area
		draw_rect(Rect2(highlight_pos - highlight_size / 2, highlight_size), Color(1, 1, 1, 0.3), false, 2.0)

func update_highlight(pos: Vector2, visible: bool):
	highlight_pos = pos
	show_highlight = visible
	queue_redraw()

func _process(_delta):
	# Update position to follow the mouse or tile cursor
	var mouse_pos = get_global_mouse_position()
	# Snap to grid (assuming 16x16 tiles)
	var snapped_pos = Vector2(floor(mouse_pos.x / 16) * 16 + 8, floor(mouse_pos.y / 16) * 16 + 8)
	update_highlight(snapped_pos, true)
