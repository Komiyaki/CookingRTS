extends PooledObject
class_name CarriedObject

@export var id: int = -1

var is_dropped: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var pickup_area: Area2D = $PickupArea
@onready var pickup_shape: CollisionShape2D = $PickupArea/CollisionShape2D
@onready var interaction_point: Marker2D = $Marker2D

func _ready() -> void:
    set_pickup_enabled(false)

func prepare_for_spawn(new_id: int, new_texture: Texture2D) -> void:
    id = new_id
    sprite.texture = new_texture
    is_dropped = false
    set_pickup_enabled(false)
    show()

func get_target_position() -> Vector2:
    return interaction_point.global_position

func get_item_id() -> int:
    return id

func can_interact() -> bool:
    return is_dropped

func set_carried(group: LittleGuyGroup) -> void:
    is_dropped = false
    set_pickup_enabled(false)
    reparent(group, true)
    position = Vector2.ZERO

func drop_to_world(world_parent: Node2D, drop_position: Vector2) -> void:
    reparent(world_parent, true)
    global_position = drop_position
    is_dropped = true
    set_pickup_enabled(true)

func set_pickup_enabled(enabled: bool) -> void:
    pickup_shape.set_deferred("disabled", not enabled)

func set_in_pan(new_parent: Node2D, new_position: Vector2, new_rotation: float) -> void:
    is_dropped = false
    set_pickup_enabled(false)
    reparent(new_parent, true)
    position = new_position
    rotation = new_rotation
    show()

func deactivate_for_pool(pool_parent: Node) -> void:
    is_dropped = false
    set_pickup_enabled(false)
    reparent(pool_parent, true)
    position = Vector2.ZERO
    rotation = 0.0
    hide()
