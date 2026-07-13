extends Node
class_name LittleGuyGroup

@export var formation_spacing: float = 25.0

var units: Array[LittleGuy] = []
var group_id: int = -1
var target_pos: Vector2
var order_queue: Array[LittleGuyOrder] = []
var current_order: LittleGuyOrder = null

func _ready() -> void:
    set_process(false)

func setup(_group_id: int, new_units: Array[LittleGuy]) -> void:
    group_id = _group_id
    for unit in new_units:
        add_unit(unit)

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
    units.erase(unit)
    if unit.current_group == self:
        unit.current_group = null

func add_order(order: LittleGuyOrder) -> void:
    order_queue.append(order)
    print("Group ", group_id, " queue: ", order_queue)
    if current_order == null:
        start_next_order()

func start_next_order() -> void:
    if order_queue.is_empty():
        current_order = null
        set_process(false)
        print("Group ", group_id, " finished its order queue.")
        return
    current_order = order_queue.pop_front()
    match current_order.action_type:
        LittleGuyOrder.ActionType.MOVE:
            move_group_to(current_order.get_target_position())
        _:
            print("This order type is not implemented yet.")
            current_order = null
            start_next_order()
            return
    set_process(true)

func _process(_delta: float) -> void:
    if current_order == null:
        return
    if current_order.action_type == LittleGuyOrder.ActionType.MOVE:
        if all_units_reached_target():
            complete_current_order()

func complete_current_order() -> void:
    print("Group ",group_id," completed order at ",current_order.get_target_position())
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
    var columns: int = ceili(sqrt(float(count)))
    var rows: int = ceili(float(count) / float(columns))
    var grid_width: float = float(columns - 1) * formation_spacing
    var grid_height: float = float(rows - 1) * formation_spacing
    for i in range(count):
        var unit: LittleGuy = units[i]
        var col: int = i % columns
        var row: int = floori(float(i) / float(columns))
        var offset := Vector2(float(col) * formation_spacing - grid_width / 2.0,float(row) * formation_spacing - grid_height / 2.0)
        unit.move_to(pos + offset)

func disband() -> void:
    order_queue.clear()
    current_order = null
    for unit in units:
        if is_instance_valid(unit) and unit.current_group == self:
            unit.current_group = null
    units.clear()
    queue_free()

func replace_orders(order: LittleGuyOrder) -> void:
    order_queue.clear()
    current_order = null
    add_order(order)
