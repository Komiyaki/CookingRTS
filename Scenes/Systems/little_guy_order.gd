extends RefCounted
class_name LittleGuyOrder

enum ActionType {
MOVE,
PICKUP,
PUTDOWN,
INTERACT
}

var action_type: ActionType
var target_objective: Objective = null
var target_position: Vector2 = Vector2.ZERO
var item_id: int = -1


func _init(
    _action_type: ActionType,
    _target_objective: Objective = null,
    _target_position: Vector2 = Vector2.ZERO,
    _item_id: int = -1
) -> void:
    action_type = _action_type
    target_objective = _target_objective
    target_position = _target_position
    item_id = _item_id


func get_target_position() -> Vector2:
    if target_objective != null and is_instance_valid(target_objective):
        return target_objective.get_target_position()
    return target_position
