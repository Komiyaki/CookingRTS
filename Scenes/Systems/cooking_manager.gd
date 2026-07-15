extends Node
class_name CookingManager
signal cooking_started(duration: float)
signal ingredient_added(item_id: int, new_amount: int)
signal cooking_finished(ingredients: Dictionary)
@export var cooking_duration: float = 45.0
@onready var cook_timer: Timer = $CookTimer
var ingredients: Dictionary = {}
var last_finished_ingredients: Dictionary = {}

func _ready() -> void:
    cook_timer.one_shot = true
    cook_timer.wait_time = cooking_duration
    cook_timer.timeout.connect(_on_cook_timer_timeout)

func add_ingredient(item_id: int, amount: int = 1) -> bool:
    if item_id < 0 or amount <= 0:
        return false
    if not CarriedObjectDictionary.has_id(item_id):
        return false
    if cook_timer.is_stopped():
        ingredients.clear()
        cook_timer.start(cooking_duration)
        cooking_started.emit(cooking_duration)
    var new_amount: int = int(ingredients.get(item_id, 0)) + amount
    ingredients[item_id] = new_amount
    ingredient_added.emit(item_id, new_amount)
    return true

func is_cooking() -> bool:
    return not cook_timer.is_stopped()

func get_time_left() -> float:
    return cook_timer.time_left

func get_ingredients() -> Dictionary:
    return ingredients.duplicate(true)

func get_last_finished_ingredients() -> Dictionary:
    return last_finished_ingredients.duplicate(true)

func _on_cook_timer_timeout() -> void:
    last_finished_ingredients = ingredients.duplicate(true)
    ingredients.clear()
    cooking_finished.emit(last_finished_ingredients.duplicate(true))
