extends Node2D
class_name LittleGuy

const MOVE_SPEED: float = 132.0
const ARRIVAL_DISTANCE: float = 0.1
var target_pos: Vector2
var current_group: LittleGuyGroup = null
@onready var selector = get_node_or_null("Selector")

func _ready() -> void:
    if selector:
        selector.hide()
    add_to_group("selectable-units")
    target_pos = global_position
    set_process(false)

func _process(delta: float) -> void:
    global_position = global_position.move_toward(target_pos,MOVE_SPEED * delta)
    if has_reached_target():
        global_position = target_pos
        set_process(false)

func move_to(pos: Vector2) -> void:
    target_pos = pos
    set_process(true)

func has_reached_target() -> bool:
    return global_position.distance_to(target_pos) <= ARRIVAL_DISTANCE

func is_in_selection_box(box: Rect2) -> bool:
    var screen_pos := get_global_transform_with_canvas().origin
    return box.has_point(screen_pos)

func select() -> void:
    if selector:
        selector.show()
    add_to_group("selected-units")

func deselect() -> void:
    if selector:
        selector.hide()
    remove_from_group("selected-units")
