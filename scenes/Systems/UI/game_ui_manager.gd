extends Control
class_name GameUIManager

@export var debug_ui_manager: DebugUIManager
@export var ticket_ui_manager: TicketUIManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    _check_dependencies()

func first_setup(game_manager: GameManager) -> void:
    debug_ui_manager.connect_labels(game_manager)

func _check_dependencies() -> void:
    if debug_ui_manager == null:
        push_error("No debug_ui_manager set on %s" % name)
    if ticket_ui_manager == null:
        push_error("No ticket_ui_manager set on %s" % name)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
