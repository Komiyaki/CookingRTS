extends Node
class_name GameManager

const debug: bool = true

enum GameState {
FIRST_LOAD,
COUNTDOWN,
SPAWNING,
INTERROUND,
PAUSED,
ROUND_SWITCH,
GAME_OVER,
RESTART,
}

var game_state: GameState = GameState.FIRST_LOAD:
    set(value):
        game_state = value
        if(debug):
            # ui_manager.display_game_state(GameState.keys()[game_state])
            pass

@export var carried_object_pool: ObjectPooler
# @export var ui_manager
@export var gm_round_timer: Timer

@export var carried_object_texture: String = "res://icon.svg"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    game_state = GameState.FIRST_LOAD
    _check_dependencies()

func _check_dependencies() -> void:
    # if ui_manager == null:
    #     push_error("No ui_manager set on %s" % name)
    if carried_object_pool == null:
        push_error("No carried_object_pool set on %s" % name)
    if gm_round_timer == null:
        push_error("No gm_round_timer set on %s" % name)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

    match game_state:
        GameState.FIRST_LOAD:
            game_state = GameState.FIRST_LOAD
            print("%s performing first load" % name)
            # for now dont do much, just start spawning
            # might play some intro animation or something idk
            game_state = GameState.ROUND_SWITCH

        GameState.INTERROUND:
            # allow shopping for new guys??? idk
            pass

        GameState.PAUSED:
            # send signal to all subscribers that game is paused (on pause and unpause)
            pass

        GameState.ROUND_SWITCH:
            # increment round counter, load recipe data for next round, start interround timer
            pass

        GameState.GAME_OVER:
            # show stats
            # allow restart, or exit to menu
            pass

        GameState.RESTART:
            pass

        _:
            push_error("Unexpected GameState value on %s" % name)

    pass
