extends AspectRatioContainer
class_name TimerUIManager

@export var timer_label: Label

var update_round_timer: bool = true

var _gm_round_timer: Timer
var _gm_interround_timer: Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.

func first_setup(game_manager: GameManager) -> void:
    _gm_round_timer = game_manager.gm_round_timer
    _gm_interround_timer = game_manager.gm_interround_timer

    game_manager.game_state_event.connect(_process_state_change)

func _process_state_change(_previous_state: GameData.GameState, new_state: GameData.GameState):
    match new_state:
        GameData.GameState.ROUND_SWITCH:
            update_round_timer = true
        GameData.GameState.INTERROUND:
            update_round_timer = false
        _:
            pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if update_round_timer:
        timer_label.text = "%d:%02d" % [floor(_gm_round_timer.time_left / 60), int(_gm_round_timer.time_left) % 60]
    else:
        timer_label.text = "%d:%02d" % [floor(_gm_interround_timer.time_left / 60), int(_gm_interround_timer.time_left) % 60]
