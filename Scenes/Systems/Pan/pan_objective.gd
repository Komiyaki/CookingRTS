extends Objective
class_name PanObjective

@export var cooking_manager: CookingManager
@export var cook_timer: Timer
@export var timer_indicator: TextureProgressBar
@export var ingredient_visuals: Node2D
@export var placement_shape: CollisionShape2D
@export var carried_object_pooler: CarriedObjectPooler
@export var placement_padding: float = 16.0

var ingredient_objects: Array[CarriedObject] = []
var random: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
    random.randomize()
    timer_indicator.max_value = cook_timer.wait_time
    cook_timer.timeout.connect(_on_cook_timer_timeout)

func can_interact() -> bool:
    return true

func can_accept_item(item_id: int) -> bool:
    return CarriedObjectDictionary.has_id(item_id)

func add_carried_object(object: CarriedObject) -> bool:
    if not can_accept_item(object.id):
        return false
    if not cooking_manager.add_ingredient(object.id, 1):
        return false
    var visual_position: Vector2 = get_random_placement_position()
    var visual_rotation: float = random.randf_range(-PI, PI)
    object.set_in_pan(ingredient_visuals, visual_position, visual_rotation)
    ingredient_objects.append(object)
    return true

func add_ingredient(item_id: int, amount: int = 1) -> bool:
    if not can_accept_item(item_id):
        return false
    return cooking_manager.add_ingredient(item_id, amount)

func get_random_placement_position() -> Vector2:
    var shape_local_position: Vector2
    if placement_shape.shape is CircleShape2D:
        var circle: CircleShape2D = placement_shape.shape
        var usable_radius: float = circle.radius - placement_padding
        var angle: float = random.randf_range(0.0, TAU)
        var distance: float = sqrt(random.randf()) * usable_radius
        shape_local_position = Vector2(cos(angle), sin(angle)) * distance
    else:
        var rectangle: RectangleShape2D = placement_shape.shape
        var half_width: float = rectangle.size.x / 2.0 - placement_padding
        var half_height: float = rectangle.size.y / 2.0 - placement_padding
        shape_local_position = Vector2(random.randf_range(-half_width, half_width), random.randf_range(-half_height, half_height))
    var world_position: Vector2 = placement_shape.to_global(shape_local_position)
    return ingredient_visuals.to_local(world_position)

func is_cooking() -> bool:
    return cooking_manager.is_cooking()

func get_time_left() -> float:
    return cooking_manager.get_time_left()

func get_ingredients() -> Dictionary:
    return cooking_manager.get_ingredients()

func get_last_finished_ingredients() -> Dictionary:
    return cooking_manager.get_last_finished_ingredients()

func clear_visual_ingredients() -> void:
    for object in ingredient_objects:
        object.deactivate_for_pool(carried_object_pooler)
    ingredient_objects.clear()

func _on_cook_timer_timeout() -> void:
    clear_visual_ingredients()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    timer_indicator.tooltip_text = "%d:%02d" % [floor(cook_timer.time_left / 60), int(cook_timer.time_left) % 60]
    timer_indicator.value = cook_timer.time_left
    pass
