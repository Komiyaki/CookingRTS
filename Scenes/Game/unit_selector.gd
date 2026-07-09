extends Control

@onready var group_manager = $"../../Groups/GroupManager"

var selecting: bool = false
var drag_start: Vector2 = Vector2.ZERO
var select_box: Rect2 = Rect2()

const CLICK_THRESHOLD: float = 8.0
const CLICK_SELECT_SIZE: Vector2 = Vector2(24, 24)

func _input(e: InputEvent) -> void:
    if e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_RIGHT and e.pressed:
        print("Right Click detected!")
        var target_pos: Vector2 = screen_to_world(e.position)
        print("Target Pos:", target_pos)
        var selected_units: Array[LittleGuy] = []
        for unit in get_tree().get_nodes_in_group("selected-units"):
            print("Found selected unit:", unit)
            if unit is LittleGuy:
                selected_units.append(unit)
        print("Selected units count: ", selected_units.size())
        print("Group manager: ", group_manager)
        if selected_units.size() > 0:
            var new_group: LittleGuyGroup = group_manager.create_group(selected_units)
            print("New group: ", new_group)
            if new_group != null:
                new_group.move_group_to(target_pos)
            clear_selected_units()
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
            var is_click: bool = drag_start.distance_to(e.position) < CLICK_THRESHOLD
            if is_click:
                select_box = Rect2(e.position - CLICK_SELECT_SIZE / 2.0,CLICK_SELECT_SIZE)
            else:
                select_box = make_rect_from_points(drag_start, e.position)
            update_selected_units(additive, is_click)
            queue_redraw()
    elif selecting and e is InputEventMouseMotion:
        select_box = make_rect_from_points(drag_start, e.position)
        queue_redraw()

func _draw() -> void:
    if not selecting:
        return
    if select_box.size.length() < CLICK_THRESHOLD:
        return
    draw_rect(select_box, Color("#00ff0066"), true)
    draw_rect(select_box, Color("#00ff00"), false, 2.0)

func update_selected_units(additive: bool, is_click: bool) -> void:
    if not additive:
        clear_selected_units()
    for unit in get_tree().get_nodes_in_group("selectable-units"):
        if not unit.has_method("is_in_selection_box"):
            continue
        if unit.is_in_selection_box(select_box):
            if additive and is_click:
                if unit.is_in_group("selected-units"):
                    unit.deselect()
                else:
                    unit.select()
            else:
                unit.select()

func clear_selected_units() -> void:
    for unit in get_tree().get_nodes_in_group("selected-units"):
        if unit.has_method("deselect"):
            unit.deselect()

func make_rect_from_points(a: Vector2, b: Vector2) -> Rect2:
    var x_min: float = min(a.x, b.x)
    var y_min: float = min(a.y, b.y)
    var width: float = max(a.x, b.x) - x_min
    var height: float = max(a.y, b.y) - y_min
    return Rect2(x_min, y_min, width, height)

func screen_to_world(screen_pos: Vector2) -> Vector2:
    var canvas_transform := get_viewport().get_canvas_transform()
    return canvas_transform.affine_inverse() * screen_pos

func _ready() -> void:
    print("Group manager found: ", group_manager)
