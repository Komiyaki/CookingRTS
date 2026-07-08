extends Node2D

func _ready() -> void:
	$Selector.hide()
	add_to_group("selectable-units")


func is_in_selection_box(box: Rect2) -> bool:
	var screen_pos := get_global_transform_with_canvas().origin
	return box.has_point(screen_pos)


func select() -> void:
	$Selector.show()
	add_to_group("selected-units")


func deselect() -> void:
	$Selector.hide()
	remove_from_group("selected-units")
