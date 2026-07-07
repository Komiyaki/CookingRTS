extends Node
class_name ObjectPooler

@export_category("Pool Config")
@export var object_scene: PackedScene
@export var object_name: String = "Object"
@export var initial_object_count: int = 10
@export var pool_increase_amount: int = 3
@export var pool_increase_threshold: int = 1

@export_category("Pool Internal")
@export var object_pool_inactive: Dictionary
@export var object_pool_active: Dictionary
@export var object_pool_count: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:


    # Load PackedScene of enemy
    # object_scene = load(GameData.ENEMY_SCENE_PATH)

    # Init empty dictionaries
    object_pool_active = Dictionary()
    object_pool_inactive = Dictionary()

    # Check enemy is PooledObject
    var new_object = object_scene.instantiate()
    assert(new_object is PooledObject)

    # Crash if not, add first to dict if so
    _add_object_to_pool(new_object)

    # Fill to initial capacity
    _fill_pool_initial()



func _fill_pool_initial() -> void:
    _add_objects_to_pool(initial_object_count)

func _add_object_to_pool(new_object: PooledObject) -> void:
    add_child(new_object)
    new_object.name = "%s %d" % [object_name, object_pool_count]
    new_object.set_inactive()
    object_pool_inactive.set(object_pool_count, new_object)
    object_pool_count += 1

func _add_objects_to_pool(count: int = 0) -> void:
    print("%s populating %s object pool to %d objects" % [name, object_name, initial_object_count])
    while object_pool_count < count:
        var new_object = object_scene.instantiate()
        _add_object_to_pool(new_object)

func spawn_object(location: Vector2) -> PooledObject:
    # Add to pool if running low
    if len(object_pool_inactive) <= pool_increase_threshold:
        _add_objects_to_pool(pool_increase_amount)
        print("%s Added %d additional %s objects to pool" % [name, object_name, pool_increase_amount])

    # Move object from inactive to active
    var object_id: int = object_pool_inactive.keys()[0]
    var object: PooledObject = object_pool_inactive.get(object_id)
    object_pool_active.set(object_id, object)
    object_pool_inactive.erase(object_id)

    object.position = location
    object.set_active()
    return object
