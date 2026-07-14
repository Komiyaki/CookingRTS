extends Node2D
class_name LittleGuyGroupManager

@onready var carried_object_pooler: CarriedObjectPooler = $"../../CarriedObjectPooler"
@onready var objectives_container: Node2D = $"../../Objectives"

var next_group_id: int = 1
var active_groups: Array[LittleGuyGroup] = []

func create_group(units: Array) -> LittleGuyGroup:
    if units.is_empty():
        return null
    var group := LittleGuyGroup.new()
    add_child(group)
    group.setup(next_group_id, units, carried_object_pooler, objectives_container)
    next_group_id += 1
    active_groups.append(group)
    return group

func remove_group(group: LittleGuyGroup) -> void:
    if active_groups.has(group):
        active_groups.erase(group)
    group.disband()
