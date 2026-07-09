extends Node
class_name LittleGuyGroup

@export var formation_spacing: float = 32.0

var units: Array[LittleGuy] = []
var group_id: int = -1
var target_pos: Vector2

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

func move_group_to(pos: Vector2) -> void:
	target_pos = pos
	if units.is_empty():
		return
	var count := units.size()
	var columns := ceili(sqrt(float(count)))
	var rows := ceili(float(count) / float(columns))
	var grid_width := float(columns - 1) * formation_spacing
	var grid_height := float(rows - 1) * formation_spacing
	for i in range(count):
		var unit := units[i]
		var col := i % columns
		var row := floori(float(i) / float(columns))
		var offset := Vector2(float(col) * formation_spacing - grid_width / 2.0,float(row) * formation_spacing - grid_height / 2.0)
		unit.move_to(pos + offset)

func disband() -> void:
	for unit in units:
		if is_instance_valid(unit) and unit.current_group == self:
			unit.current_group = null
	units.clear()
	queue_free()
