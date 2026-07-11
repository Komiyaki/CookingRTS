extends AspectRatioContainer
class_name DebugUIManager

@export var round_label: Label
@export var state_label: Label

@export var debug_visible: bool = true

func connect_labels(game_manager: GameManager) -> void:
    game_manager.round_event.connect(_update_round_label)
    game_manager.game_state_event.connect(_update_state_label)

func _update_round_label(round_num: int) -> void:
    round_label.text = str(round_num)

func _update_state_label(_old_state: GameData.GameState, new_state: GameData.GameState) -> void:
    state_label.text = GameData.GameState.keys()[new_state]
