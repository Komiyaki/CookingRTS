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
@export var item_id: int = -1
@export var interaction_radius: float = 24.0

@onready var interaction_point: Marker2D = $Marker2D

func _ready() -> void:
    if objective_kind != ObjectiveKind.INGREDIENT_SOURCE:
        return
    if item_id == -1:
        push_warning(name + " has no item ID assigned.")
    elif not CarriedObjectDictionary.has_id(item_id):
        push_warning(name + " has an invalid item ID: " + str(item_id))

func get_target_position() -> Vector2:
    return interaction_point.global_position

func get_item_name() -> String:
    return CarriedObjectDictionary.get_item_name(item_id)

func get_sprite_name() -> String:
    return CarriedObjectDictionary.get_sprite_name(item_id)

func get_item_id() -> int:
    return item_id

func can_interact() -> bool:
    return true
