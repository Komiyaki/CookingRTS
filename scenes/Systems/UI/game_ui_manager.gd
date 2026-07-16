extends Control
class_name GameUIManager

@export var debug_ui_manager: DebugUIManager
@export var timer_ui_manager: TimerUIManager
@export var ticket_ui_manager: TicketUIManager

@export var playing_ui: Control
@export var pause_ui: Control
@export var pause_gray: ColorRect

@export var restart_screen: Container
@export var restart_button: Button
@export var exit_button: Button
@export var highscore_label: Label
@export var score_label: Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    _check_dependencies()

func first_setup(game_manager: GameManager) -> void:
    debug_ui_manager.connect_labels(game_manager)
    timer_ui_manager.first_setup(game_manager)
    game_manager.pause_event.connect(_toggle_pause)

func _check_dependencies() -> void:
    if debug_ui_manager == null:
        push_error("No debug_ui_manager set on %s" % name)
    if ticket_ui_manager == null:
        push_error("No ticket_ui_manager set on %s" % name)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass


func _toggle_pause(is_paused: bool) -> void:
    if is_paused:
        pause_ui.visible = true
        pause_gray.visible = true
        # playing_ui.visible = false
    else:
        pause_ui.visible = false
        pause_gray.visible = false
        # playing_ui.visible = true
    pass

func do_gameover(high_score: int, current_score: int):
    highscore_label.text = str(high_score)
    score_label.text = str(current_score)
    restart_screen.visible = true

    pass
