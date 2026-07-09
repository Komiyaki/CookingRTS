extends Node
class_name LittleGuyGroupManager

@export var little_guy_group_scene: PackedScene

var next_group_id: int = 1
var active_groups: Array[LittleGuyGroup] = []

func create_group(units: Array[LittleGuy]) -> LittleGuyGroup:
	if units.is_empty():
		return null
	var group: LittleGuyGroup = little_guy_group_scene.instantiate()
	add_child(group)
	group.setup(next_group_id, units)
	next_group_id += 1
	active_groups.append(group)
	return group

func remove_group(group: LittleGuyGroup) -> void:
	if active_groups.has(group):
		active_groups.erase(group)
	group.disband()
