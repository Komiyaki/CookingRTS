extends Node2D
class_name Objective

enum ObjectiveKind {
    INGREDIENT_SOURCE,
    PAN,
    PLATE,
    TRASH,
    MOVEMENT
}

@export var objective_kind: ObjectiveKind = ObjectiveKind.INGREDIENT_SOURCE
@export var item_id: int = 0b011010 # default carrot for testing
@export var interaction_radius: float = 24.0


func get_target_position() -> Vector2:
    return global_position


func get_item_name() -> String:
    return IDDictionary.get_name(item_id)


func get_sprite_name() -> String:
    return IDDictionary.get_sprite_name(item_id)
