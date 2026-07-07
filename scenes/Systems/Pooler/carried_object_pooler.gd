extends ObjectPooler
class_name CarriedObjectPooler

@export var game_manager: GameManager

func _ready() -> void:
    _check_dependencies()

    super()

func _check_dependencies() -> void:
    if game_manager == null:
        push_error("No game_manager set on %s" % name)

func spawn_carried_object(location: Vector2, id: int) -> CarriedObject:
    var object: CarriedObject =  super.spawn_object(location)

    # Get object from super() and set sprite, id manually
    assert(object is CarriedObject)
    object.id = id
    object.sprite.texture = load(game_manager.carried_object_texture)

    return object
