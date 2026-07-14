extends RefCounted
class_name LittleGuyOrder

enum ActionType {
    MOVE,
    PICKUP,
    PUTDOWN,
    INTERACT
}

var action_type: ActionType = ActionType.MOVE
var target_position: Vector2 = Vector2.ZERO
var target_objective: Node2D = null
var item_id: int = -1

static func make_move_order(pos: Vector2) -> LittleGuyOrder:
    var order := LittleGuyOrder.new()
    order.action_type = ActionType.MOVE
    order.target_position = pos
    return order

func get_target_position() -> Vector2:
    if target_objective != null and is_instance_valid(target_objective):
        if target_objective.has_method("get_target_position"):
            return target_objective.get_target_position()
    return target_position
