extends Node2D

var dragging := false
var selected := []
var drag_start := Vector2.ZERO
var drag_end := Vector2.ZERO
var select_rect := RectangleShape2D.new()

const CLICK_THRESHOLD := 8.0

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging = true
			drag_start = get_global_mouse_position()
			drag_end = drag_start
			queue_redraw()
		elif dragging:
			dragging = false
			drag_end = get_global_mouse_position()
			var drag_distance := drag_start.distance_to(drag_end)
			if drag_distance < CLICK_THRESHOLD:
				_clear_selection()
			else:
				_select_objects()
			queue_redraw()
	if event is InputEventMouseMotion and dragging:
		drag_end = get_global_mouse_position()
		queue_redraw()


func _draw() -> void:
	if dragging:
		var local_start := to_local(drag_start)
		var local_end := to_local(drag_end)
		var rect := Rect2(local_start, local_end - local_start).abs()
		draw_rect(rect, Color(0.5, 0.5, 0.5), false, 2.0)
	for obj in selected:
		if not is_instance_valid(obj):
			continue
		_draw_highlight_around_object(obj)

func _select_objects() -> void:
	_clear_selection()
	var rect := Rect2(drag_start, drag_end - drag_start).abs()
	select_rect.size = rect.size
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = select_rect
	query.transform = Transform2D(0.0, rect.get_center())
	query.collide_with_areas = true
	query.collide_with_bodies = true
	var space := get_world_2d().direct_space_state
	var hits := space.intersect_shape(query, 128)
	for hit in hits:
		var collider = hit["collider"]
		selected.append(collider)
	print(selected)

func _clear_selection() -> void:
	selected.clear()

func _draw_highlight_around_object(obj: Node) -> void:
	var collision_shape := obj.get_node_or_null("CollisionShape2D")
	if collision_shape == null:
		return
	var shape = collision_shape.shape
	if shape is RectangleShape2D:
		var size: Vector2 = shape.size
		var center := to_local(collision_shape.global_position)
		var rect := Rect2(center - size / 2.0, size)
		draw_rect(rect, Color(1.0, 1.0, 0.0), false, 3.0)
	elif shape is CircleShape2D:
		var center := to_local(collision_shape.global_position)
		draw_arc(center, shape.radius, 0.0, TAU, 32, Color(1.0, 1.0, 0.0), 3.0)
