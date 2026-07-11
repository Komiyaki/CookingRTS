extends ObjectPooler
class_name CarriedObjectPooler

@export var sprite_folder: String = "res://Asset/Sprites/"
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
    var object: CarriedObject =  super.spawn_object(location)

    # Get object from super() and set sprite, id manually
    assert(object is CarriedObject)
    object.id = id
    object.sprite.texture = sprite_dict.get(id)

    return object
