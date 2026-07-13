extends Area2D
class_name Objective

enum ObjectiveKind {
    INGREDIENT_SOURCE,
    PAN,
    PLATE,
    TRASH,
    MOVEMENT
}

@export var objective_kind: ObjectiveKind = ObjectiveKind.INGREDIENT_SOURCE
@export var item_id: int = 0b011010
@export var interaction_radius: float = 24.0

@onready var interaction_point: Marker2D = $Marker2D

func get_target_position() -> Vector2:
    return interaction_point.global_position

func get_item_name() -> String:
    return CarriedObjectDictionary.get_name(item_id)

func get_sprite_name() -> String:
    return CarriedObjectDictionary.get_sprite_name(item_id)
