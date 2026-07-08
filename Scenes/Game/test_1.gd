extends Node2D

const MOVE_SPEED: float = 200.0
var target_pos: Vector2
@onready var selector = $Selector

func _ready() -> void:
	selector.hide()
	add_to_group("selectable-units")
	set_process(false)
	
func _process(delta: float) -> void:
	global_position = global_position.move_toward(target_pos, MOVE_SPEED * delta)
	if global_position.distance_to(target_pos) < 0.1:
		global_position = target_pos
		set_process(false)

func move(_target_pos: Vector2):
	target_pos = _target_pos
	set_process(true)

func is_in_selection_box(box: Rect2) -> bool:
	var screen_pos := get_global_transform_with_canvas().origin
	return box.has_point(screen_pos)

func select() -> void:
	selector.show()
	add_to_group("selected-units")

func deselect() -> void:
	selector.hide()
	remove_from_group("selected-units")
