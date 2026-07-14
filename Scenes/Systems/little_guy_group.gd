extends Node2D
class_name LittleGuyGroup

@export var formation_spacing: float = 25.0
@export var carried_object_offset: Vector2 = Vector2(0, -50)

var carried_object_pooler: CarriedObjectPooler
var carried_object: CarriedObject = null
var units: Array[LittleGuy] = []
var group_id: int = -1
var target_pos: Vector2
var order_queue: Array[LittleGuyOrder] = []
var current_order: LittleGuyOrder = null

func _ready() -> void:
    set_process(false)

func setup(_group_id: int, new_units: Array[LittleGuy], _carried_object_pooler: CarriedObjectPooler) -> void:
    group_id = _group_id
    carried_object_pooler = _carried_object_pooler
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
    units.erase(unit)
    if unit.current_group == self:
        unit.current_group = null

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
    update_group_position()
    if current_order == null:
        return
    if current_order.action_type == LittleGuyOrder.ActionType.MOVE:
        if all_units_reached_target():
            complete_current_order()

func complete_current_order() -> void:
    print("Group completed current order")
    print("Current objective: ", current_order.target_objective)
    print("Current item ID: ", current_order.item_id)
    if current_order.target_objective != null:
        print("Testing carried item attachment")
        attach_carried_item(current_order.item_id)
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
    print("attach_carried_item called with ID: ", item_id)
    if item_id < 0:
        print("FAILED: invalid item ID")
        return
    if carried_object_pooler == null:
        print("FAILED: carried_object_pooler is null")
        return
    print("Pooler found: ", carried_object_pooler)
    print("Sprite dictionary has ID: ", carried_object_pooler.sprite_dict.has(item_id))
    print("Texture for ID: ", carried_object_pooler.sprite_dict.get(item_id))
    if carried_object != null and is_instance_valid(carried_object):
        print("Updating existing carried object")
        carried_object.id = item_id
        carried_object.sprite.texture = carried_object_pooler.sprite_dict.get(item_id)
        return
    update_group_position()
    var spawn_position := global_position + carried_object_offset
    print("Spawning carried object at: ", spawn_position)
    carried_object = carried_object_pooler.spawn_carried_object(spawn_position, item_id)
    print("Spawn result: ", carried_object)
    if carried_object == null:
        print("FAILED: pooler returned null")
        return
    print("Carried object sprite: ", carried_object.sprite)
    print("Carried object texture: ", carried_object.sprite.texture)
    carried_object.reparent(self, true)
    carried_object.position = carried_object_offset
    print("New parent: ", carried_object.get_parent())
    print("Local carried-object position: ", carried_object.position)
