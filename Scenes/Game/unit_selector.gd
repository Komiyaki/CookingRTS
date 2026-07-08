extends Control

var selecting: bool = false
var drag_start: Vector2
var select_box: Rect2

const CLICK_THRESHOLD := 8.0
const CLICK_SELECT_SIZE := Vector2(60, 60)


func _input(e: InputEvent) -> void:
	if e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_RIGHT and e.pressed:
		var target_pos: Vector2 = screen_to_world(e.position)
		move_selected_units(target_pos)
		return
		
	if e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT:
		if e.pressed:
			selecting = true
			drag_start = e.position
			select_box = Rect2(drag_start, Vector2.ZERO)
			queue_redraw()
		else:
			selecting = false
			var additive: bool = Input.is_key_pressed(KEY_SHIFT)
			if drag_start.distance_to(e.position) < CLICK_THRESHOLD:
				select_box = Rect2(e.position - CLICK_SELECT_SIZE / 2.0,CLICK_SELECT_SIZE)
			else:
				var x_min = min(drag_start.x, e.position.x)
				var y_min = min(drag_start.y, e.position.y)
				select_box = Rect2(x_min,y_min,max(drag_start.x, e.position.x) - x_min,max(drag_start.y, e.position.y) - y_min)
			update_selected_units(additive)
			queue_redraw()
	elif selecting and e is InputEventMouseMotion:
		var x_min = min(drag_start.x, e.position.x)
		var y_min = min(drag_start.y, e.position.y)
		select_box = Rect2(x_min,y_min,max(drag_start.x, e.position.x) - x_min,max(drag_start.y, e.position.y) - y_min)
		queue_redraw()

func move_selected_units(pos: Vector2):
	var units := get_tree().get_nodes_in_group("selected-units")
	if units.size() == 0:
		return
	var ref_unit = units[0]
	var ref_pos: Vector2 = ref_unit.global_position
	for unit in units:
		var offset: Vector2 = unit.global_position - ref_pos
		unit.move(pos + offset)

func _draw() -> void:
	if not selecting:
		return
	if select_box.size.length() < CLICK_THRESHOLD:
		return
	draw_rect(select_box, Color("#00ff0066"))
	draw_rect(select_box, Color("#00ff00"), false, 2.0)

func update_selected_units(additive: bool) -> void:
	if not additive:
		clear_selected_units()
	for unit in get_tree().get_nodes_in_group("selectable-units"):
		if unit.is_in_selection_box(select_box):
			unit.select()

func clear_selected_units() -> void:
	for unit in get_tree().get_nodes_in_group("selected-units"):
		unit.deselect()

func screen_to_world(screen_pos: Vector2) -> Vector2:
	var canvas_transform := get_viewport().get_canvas_transform()
	return canvas_transform.affine_inverse() * screen_pos
