extends Control

@onready var group_manager = $"../../Groups/GroupManager"
@export_flags_2d_physics var objective_collision_mask: int = 2

var selecting: bool = false
var drag_start: Vector2 = Vector2.ZERO
var select_box: Rect2 = Rect2()

const CLICK_THRESHOLD: float = 8.0
const CLICK_SELECT_SIZE: Vector2 = Vector2(24, 24)

func _ready() -> void:
    print("Group manager found: ", group_manager)

func _input(e: InputEvent) -> void:
    if e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_RIGHT and e.pressed:
        var clicked_pos: Vector2 = screen_to_world(e.position)
        var selected_units: Array[LittleGuy] = []
        for unit in get_tree().get_nodes_in_group("selected-units"):
            if unit is LittleGuy:
                selected_units.append(unit)
        if selected_units.is_empty():
            return
        var target_group: LittleGuyGroup = get_shared_group(selected_units)
        if target_group == null:
            target_group = group_manager.create_group(selected_units)
        if target_group == null:
            return
        var clicked_target: Node2D = get_interactable_at(clicked_pos)
        var new_order := LittleGuyOrder.new()
        if clicked_target != null:
            new_order.target_objective = clicked_target
            new_order.target_position = clicked_target.get_target_position()
            new_order.item_id = clicked_target.get_item_id()
            if clicked_target is CarriedObject:
                new_order.action_type = LittleGuyOrder.ActionType.PICKUP
            elif clicked_target is Objective and clicked_target.objective_kind == Objective.ObjectiveKind.INGREDIENT_SOURCE:
                new_order.action_type = LittleGuyOrder.ActionType.PICKUP
            else:
                new_order.action_type = LittleGuyOrder.ActionType.MOVE
        else:
            new_order.action_type = LittleGuyOrder.ActionType.MOVE
            new_order.target_position = clicked_pos
        print("Clicked position: ", clicked_pos)
        print("Clicked target: ", clicked_target)
        print("Order type: ", LittleGuyOrder.ActionType.find_key(new_order.action_type))
        print("Order objective: ", new_order.target_objective)
        print("Order position: ", new_order.get_target_position())
        print("Order item ID: ", new_order.item_id)
        var queue_order: bool = Input.is_key_pressed(KEY_SHIFT)
        if queue_order:
            target_group.add_order(new_order)
        else:
            target_group.replace_orders(new_order)
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
                select_box = Rect2(e.position - CLICK_SELECT_SIZE / 2.0, CLICK_SELECT_SIZE)
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

func get_shared_group(units: Array[LittleGuy]) -> LittleGuyGroup:
    if units.is_empty():
        return null
    var shared_group: LittleGuyGroup = units[0].current_group
    if shared_group == null:
        return null
    for unit in units:
        if unit.current_group != shared_group:
            return null
    if shared_group.units.size() != units.size():
        return null
    for group_unit in shared_group.units:
        if not units.has(group_unit):
            return null
    return shared_group

func get_interactable_at(world_pos: Vector2) -> Node2D:
    var query := PhysicsPointQueryParameters2D.new()
    query.position = world_pos
    query.collision_mask = objective_collision_mask
    query.collide_with_areas = true
    query.collide_with_bodies = false
    var hits := get_viewport().world_2d.direct_space_state.intersect_point(query, 16)
    for hit in hits:
        var collider: Node = hit["collider"]
        if collider is Objective:
            return collider
        if collider is Area2D:
            var parent := collider.get_parent()
            if parent is CarriedObject and parent.can_interact():
                return parent
    return null
