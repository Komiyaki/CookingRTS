extends Node2D
class_name LittleGuyGroup

signal group_disbanded(group: LittleGuyGroup)

@export var formation_radius: float = 50.0
@export var carried_object_offset: Vector2 = Vector2.ZERO

var carried_object_pooler: CarriedObjectPooler
var carried_object: CarriedObject = null
var units: Array[LittleGuy] = []
var group_id: int = -1
var target_pos: Vector2
var order_queue: Array[LittleGuyOrder] = []
var current_order: LittleGuyOrder = null
var objectives_container: Node2D

func _ready() -> void:
    set_process(false)

func setup(_group_id: int, new_units: Array[LittleGuy], _carried_object_pooler: CarriedObjectPooler, _objectives_container: Node2D) -> void:
    group_id = _group_id
    carried_object_pooler = _carried_object_pooler
    objectives_container = _objectives_container
    for unit in new_units:
        add_unit(unit)
    update_group_position()

func add_unit(unit: LittleGuy) -> void:
    if units.has(unit):
        return
    if unit.current_group != null and unit.current_group != self:
        unit.current_group.remove_unit(unit)
    units.append(unit)
    unit.current_group = self

func remove_unit(unit: LittleGuy) -> void:
    if not units.has(unit):
        return
    if units.size() == 1:
        global_position = unit.global_position
    units.erase(unit)
    if unit.current_group == self:
        unit.current_group = null
    if carried_object != null and is_instance_valid(carried_object):
        if not can_carry_item(carried_object.id):
            print(
                "Group ",
                group_id,
                " no longer has enough units to carry ",
                CarriedObjectDictionary.get_item_name(carried_object.id)
            )
            drop_current_carried_object()
    if units.is_empty():
        disband()

func add_order(order: LittleGuyOrder) -> void:
    print("Group received order")
    print("Order objective: ", order.target_objective)
    print("Order item ID: ", order.item_id)
    order_queue.append(order)
    print("Queue size: ", order_queue.size())
    if current_order == null:
        start_next_order()

func start_next_order() -> void:
    if order_queue.is_empty():
        current_order = null
        set_process(false)
        return
    current_order = order_queue.pop_front()
    match current_order.action_type:
        LittleGuyOrder.ActionType.MOVE, LittleGuyOrder.ActionType.PICKUP, LittleGuyOrder.ActionType.PUTDOWN:
            move_group_to(current_order.get_target_position())
        _:
            print("Order type is not implemented: ", current_order.action_type)
            current_order = null
            start_next_order()
            return
    set_process(true)

func _process(_delta: float) -> void:
    update_group_position()
    if current_order == null:
        return
    match current_order.action_type:
        LittleGuyOrder.ActionType.MOVE, LittleGuyOrder.ActionType.PICKUP, LittleGuyOrder.ActionType.PUTDOWN:
            if all_units_reached_target():
                complete_current_order()

func complete_current_order() -> void:
    match current_order.action_type:
        LittleGuyOrder.ActionType.PICKUP:
            execute_pickup_order(current_order)
        LittleGuyOrder.ActionType.PUTDOWN:
            execute_putdown_order(current_order)
    print("Group ", group_id, " completed order at ", current_order.get_target_position())
    current_order = null
    start_next_order()

func all_units_reached_target() -> bool:
    for unit in units:
        if not is_instance_valid(unit):
            continue
        if not unit.has_reached_target():
            return false
    return true

func move_group_to(pos: Vector2) -> void:
    target_pos = pos
    if units.is_empty():
        return
    var count: int = units.size()
    if count == 1:
        units[0].move_to(pos)
        return
    var angle_step: float = TAU / float(count)
    var starting_angle: float = -PI / 2.0
    for i in range(count):
        var angle: float = starting_angle + angle_step * float(i)
        var offset := Vector2(cos(angle), sin(angle)) * formation_radius
        units[i].move_to(pos + offset)

func disband() -> void:
    if is_queued_for_deletion():
        return
    if carried_object != null and is_instance_valid(carried_object):
        drop_current_carried_object()
    order_queue.clear()
    current_order = null
    for unit in units:
        if is_instance_valid(unit) and unit.current_group == self:
            unit.current_group = null
    units.clear()
    group_disbanded.emit(self)
    queue_free()

func replace_orders(order: LittleGuyOrder) -> void:
    order_queue.clear()
    current_order = null
    add_order(order)

func update_group_position() -> void:
    var combined_position := Vector2.ZERO
    var valid_unit_count: int = 0
    for unit in units:
        if is_instance_valid(unit):
            combined_position += unit.global_position
            valid_unit_count += 1
    if valid_unit_count > 0:
        global_position = combined_position / float(valid_unit_count)

func attach_carried_item(item_id: int) -> void:
    if item_id < 0:
        return
    if carried_object_pooler == null:
        push_error("LittleGuyGroup has no CarriedObjectPooler.")
        return
    update_group_position()
    carried_object = carried_object_pooler.spawn_carried_object(global_position, item_id)
    if carried_object == null:
        push_error("CarriedObjectPooler failed to spawn an object.")
        return
    carried_object.set_carried(self)

func _draw() -> void:
    draw_circle(Vector2.ZERO, 4.0, Color.RED)

func execute_pickup_order(order: LittleGuyOrder) -> void:
    var target: Node2D = order.target_objective
    if target == null or not is_instance_valid(target):
        return
    if not target.has_method("can_interact") or not target.can_interact():
        print("Pickup target is no longer available.")
        return
    if target is CarriedObject:
        pickup_dropped_object(target)
    elif target is Objective:
        pickup_from_objective(target)

func pickup_from_objective(objective: Objective) -> void:
    var required_units: int = CarriedObjectDictionary.get_carry_value(objective.item_id)
    if not can_carry_item(objective.item_id):
        print(
            "Group ",
            group_id,
            " cannot pick up ",
            objective.get_item_name(),
            ". Required units: ",
            required_units,
            ", current units: ",
            get_valid_unit_count()
        )
        return
    drop_current_carried_object()
    attach_carried_item(objective.item_id)
    print("Group ", group_id, " picked up ", objective.get_item_name())

func pickup_dropped_object(object: CarriedObject) -> void:
    if not object.can_interact():
        return
    var required_units: int = CarriedObjectDictionary.get_carry_value(object.id)
    if not can_carry_item(object.id):
        print(
            "Group ",
            group_id,
            " cannot pick up dropped ",
            CarriedObjectDictionary.get_item_name(object.id),
            ". Required units: ",
            required_units,
            ", current units: ",
            get_valid_unit_count()
        )
        return
    drop_current_carried_object()
    carried_object = object
    carried_object.set_carried(self)
    print(
        "Group ",
        group_id,
        " picked up dropped ",
        CarriedObjectDictionary.get_item_name(object.id)
    )

func drop_current_carried_object() -> void:
    if carried_object == null or not is_instance_valid(carried_object):
        return
    update_group_position()
    var object_to_drop: CarriedObject = carried_object
    carried_object = null
    object_to_drop.drop_to_world(objectives_container, global_position)
    print("Group ", group_id, " dropped ", CarriedObjectDictionary.get_item_name(object_to_drop.id))

func get_valid_unit_count() -> int:
    var count: int = 0
    for unit in units:
        if is_instance_valid(unit):
            count += 1
    return count

func can_carry_item(item_id: int) -> bool:
    if not CarriedObjectDictionary.has_id(item_id):
        return false
    var required_units: int = CarriedObjectDictionary.get_carry_value(item_id)
    return get_valid_unit_count() >= required_units

func has_carried_item() -> bool:
    return carried_object != null and is_instance_valid(carried_object)

func execute_putdown_order(order: LittleGuyOrder) -> void:
    if order.target_objective == null or not is_instance_valid(order.target_objective):
        return
    if not order.target_objective is PanObjective:
        return
    if not has_carried_item():
        print("Group ", group_id, " reached the pan but has no ingredient.")
        return
    var pan: PanObjective = order.target_objective
    var deposited_item_id: int = carried_object.id
    if not pan.add_ingredient(deposited_item_id):
        print("Pan rejected ", CarriedObjectDictionary.get_item_name(deposited_item_id))
        return
    consume_current_carried_object()
    print("Group ", group_id, " added ", CarriedObjectDictionary.get_item_name(deposited_item_id), " to the pan.")

func consume_current_carried_object() -> void:
    if not has_carried_item():
        return
    var object_to_consume: CarriedObject = carried_object
    carried_object = null
    object_to_consume.is_dropped = false
    object_to_consume.set_pickup_enabled(false)
    object_to_consume.reparent(carried_object_pooler, true)
    object_to_consume.hide()
