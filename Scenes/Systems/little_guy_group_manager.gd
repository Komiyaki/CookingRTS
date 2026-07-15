extends Node2D
class_name LittleGuyGroupManager

@onready var carried_object_pooler: CarriedObjectPooler = $"../../CarriedObjectPooler"
@onready var objectives_container: Node2D = $"../../Objectives"

var next_group_id: int = 1
var active_groups: Array[LittleGuyGroup] = []

func create_group(units: Array[LittleGuy]) -> LittleGuyGroup:
    if units.is_empty():
        return null
    var group := LittleGuyGroup.new()
    group.name = "LittleGuyGroup_%d" % next_group_id
    add_child(group)
    group.group_disbanded.connect(_on_group_disbanded)
    group.setup(next_group_id, units, carried_object_pooler, objectives_container)
    next_group_id += 1
    active_groups.append(group)
    return group

func remove_group(group: LittleGuyGroup) -> void:
    if active_groups.has(group):
        active_groups.erase(group)
    group.disband()

func _on_group_disbanded(group: LittleGuyGroup) -> void:
    active_groups.erase(group)
    print("Deleted empty group: ", group.name)
