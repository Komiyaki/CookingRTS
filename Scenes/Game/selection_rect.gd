extends Node2D

var dragging := false
var selected := []
var drag_start := Vector2.ZERO
var drag_end := Vector2.ZERO
var select_rect := RectangleShape2D.new()

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if selected.size() == 0:
				dragging = true
				drag_start = get_global_mouse_position()
				drag_end = drag_start
				queue_redraw()
		elif dragging:
			dragging = false
			drag_end = get_global_mouse_position()
			queue_redraw()
			_select_objects()
	if event is InputEventMouseMotion and dragging:
		drag_end = get_global_mouse_position()
		queue_redraw()

func _draw() -> void:
	if dragging:
		var local_start := to_local(drag_start)
		var local_end := to_local(drag_end)
		var rect := Rect2(local_start, local_end - local_start).abs()
		draw_rect(rect, Color(0.5, 0.5, 0.5), false, 2.0)

func _select_objects() -> void:
	var rect := Rect2(drag_start, drag_end - drag_start).abs()
	select_rect.size = rect.size
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = select_rect
	query.transform = Transform2D(0.0, rect.get_center())
	query.collide_with_areas = true
	query.collide_with_bodies = true
	var space := get_world_2d().direct_space_state
	selected = space.intersect_shape(query, 128)
	print(selected)
