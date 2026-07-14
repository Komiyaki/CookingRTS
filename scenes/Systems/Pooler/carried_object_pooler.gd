extends ObjectPooler
class_name CarriedObjectPooler

@export var sprite_folder: String = "res://Asset/Carriables/"
@export var sprite_type: String = ".svg"
@export var sprite_path_key: String = "sprite_name"

@export var sprite_dict: Dictionary

func _ready() -> void:
    super()

    _build_sprite_dict()

func _build_sprite_dict() -> void:
    sprite_dict = Dictionary()

    # Load the sprite for each ID
    for key in CarriedObjectDictionary.id_dict.keys():
        sprite_dict.set(key, load(sprite_folder + CarriedObjectDictionary.id_dict.get(key).get(sprite_path_key) + sprite_type))

func spawn_carried_object(location: Vector2, id: int) -> CarriedObject:
    var object: CarriedObject = super.spawn_object(location)
    assert(object is CarriedObject)
    object.prepare_for_spawn(id, sprite_dict.get(id))
    return object
