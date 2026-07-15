extends Objective
class_name PanObjective

@export var cooking_manager: CookingManager
@export var cook_timer: Timer
@export var timer_indicator: TextureProgressBar

func _ready() -> void:
    # set maxvalue for indicator
    timer_indicator.max_value = cook_timer.wait_time

func can_interact() -> bool:
    return true

func can_accept_item(item_id: int) -> bool:
    return CarriedObjectDictionary.has_id(item_id)

func add_ingredient(item_id: int, amount: int = 1) -> bool:
    if not can_accept_item(item_id):
        return false
    return cooking_manager.add_ingredient(item_id, amount)

func is_cooking() -> bool:
    return cooking_manager.is_cooking()

func get_time_left() -> float:
    return cooking_manager.get_time_left()

func get_ingredients() -> Dictionary:
    return cooking_manager.get_ingredients()

func get_last_finished_ingredients() -> Dictionary:
    return cooking_manager.get_last_finished_ingredients()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    timer_indicator.tooltip_text = "%d:%02d" % [floor(cook_timer.time_left / 60), int(cook_timer.time_left) % 60]
    timer_indicator.value = cook_timer.time_left
    pass
