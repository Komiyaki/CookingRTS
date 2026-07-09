extends Node
class_name GameManager

const debug: bool = true


@export var carried_object_pool: CarriedObjectPooler
@export var gm_round_timer: Timer
@export var gm_interround_timer: Timer

signal game_state_event(previous_state: GameData.GameState, new_state: GameData.GameState)
@export var game_state: GameData.GameState = GameData.GameState.FIRST_LOAD:
    set(value):
        game_state_event.emit(game_state, value)
        game_state = value

signal round_event(round_number: int)
var round_number: int = 0:
    set(value):
        round_number = value
        round_event.emit(round_number)

signal pause_event(is_paused: bool)
var is_paused: bool = false:
    set(value):
        is_paused = value
        pause_event.emit(is_paused)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    game_state = GameData.GameState.FIRST_LOAD
    _check_dependencies()


    gm_round_timer.wait_time = GameData.ROUND_TIMER_SECONDS
    gm_round_timer.one_shot = true
    gm_round_timer.timeout.connect(_round_timer_end)

    gm_interround_timer.wait_time = GameData.INTERROUND_TIMER_SECONDS
    gm_interround_timer.one_shot = true
    gm_interround_timer.timeout.connect(_interround_timer_end)

    carried_object_pool.spawn_carried_object(Vector2.ONE * 200, 0)

func _check_dependencies() -> void:
    if carried_object_pool == null:
        push_error("No carried_object_pool set on %s" % name)
    if gm_round_timer == null:
        push_error("No gm_round_timer set on %s" % name)
    if gm_interround_timer == null:
        push_error("No gm_interround_timer set on %s" % name)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

    match game_state:
        GameData.GameState.FIRST_LOAD:
            print("%s performing first load" % name)
            # for now dont do much, just start spawning
            # might play some intro animation or something idk
            game_state = GameData.GameState.ROUND_SWITCH

        GameData.GameState.PAUSED:
            # send signal to all subscribers that game is paused (on pause and unpause)
            pass

        GameData.GameState.INTERROUND:
            # allow shopping for new guys??? idk
            pass

        GameData.GameState.ROUND_SWITCH:
            # increment round counter, load recipe data for next round, start round timer
            round_number += 1
            game_state = GameData.GameState.SPAWNING

            gm_round_timer.start()
            pass

        GameData.GameState.SPAWNING:
            pass

        GameData.GameState.GAME_OVER:
            # show stats
            # allow restart, or exit to menu
            pass

        GameData.GameState.RESTART:
            pass

        _:
            push_error("Unexpected GameState value on %s" % name)

    pass

func _round_timer_end() -> void:
    game_state = GameData.GameState.INTERROUND
    gm_interround_timer.start()

func _interround_timer_end() -> void:
    game_state = GameData.GameState.ROUND_SWITCH
