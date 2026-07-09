extends ObjectPooler
class_name CarriedObjectPooler

@export var sprite_folder: String = "res://Asset/Sprites/"
@export var sprite_type: String = ".svg"
@export var sprite_path_key: String = "sprite_name"

@export var game_manager: GameManager
@export var sprite_dict: Dictionary

func _ready() -> void:
	_check_dependencies()

	super()

    _build_sprite_dict()

func _check_dependencies() -> void:
	if game_manager == null:
		push_error("No game_manager set on %s" % name)

func _build_sprite_dict() -> void:
    sprite_dict = Dictionary()

    for key in IDDictionary.id_dict.keys():
        # sprite_dict.set(key, Image.load_from_file(sprite_folder + IDDictionary.id_dict.get(key).get(sprite_path_key) + sprite_type))
        sprite_dict.set(key, load(sprite_folder + IDDictionary.id_dict.get(key).get(sprite_path_key) + sprite_type))

func spawn_carried_object(location: Vector2, id: int) -> CarriedObject:
	var object: CarriedObject =  super.spawn_object(location)

<<<<<<< Updated upstream
    # Get object from super() and set sprite, id manually
    assert(object is CarriedObject)
    object.id = id
    object.sprite.texture = sprite_dict.get(id)
=======
	# Get object from super() and set sprite, id manually
	assert(object is CarriedObject)
	object.id = id
	object.sprite.texture = load(game_manager.carried_object_texture)
>>>>>>> Stashed changes

	return object
